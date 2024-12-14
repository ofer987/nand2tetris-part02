#!/usr/bin/env ruby
# frozen_string_literal: true

module VMTranslator
  class Parser
    attr_reader :program_counter

    def put_start_program
      statements = []
      output = <<~PROGRAM_START
        (PROGRAM_START)
        // @#{VMTranslator::RAM::STACK_RAM_INDEX}
        // D=A

        // @#{VMTranslator::RAM::STACK_ADDRESS_LOCATION}
        // M=D
      PROGRAM_START

      statements.concat output.split("\n")
      statements.concat << "\n"

      print(statements)
    end

    def put_end_program
      statements = []
      output = <<~PROGRAM_END
        (PROGRAM_END)

        @PROGRAM_END
        0;JMP
      PROGRAM_END

      statements.concat output.split("\n")
      statements.concat << "\n"

      print(statements)
    end

    def initialize(lines)
      # Remove leading and trailing whitespace
      @lines = Array(lines).map(&:strip)

      @functions = {}
      @last_function_end_address_space_index = nil
      @program_counter = 0
      @stack = VMTranslator::Stack.new
      @constant_ram = VMTranslator::Constant.new
      @local_ram = VMTranslator::Local.new
      @argument_ram = VMTranslator::Argument.new
      @this_ram = VMTranslator::This.new
      @that_ram = VMTranslator::That.new
      @temp_ram = VMTranslator::Temp.new
      @pointer_ram = VMTranslator::Pointer.new
      @static_ram = VMTranslator::Static.new
    end

    def parse
      lines.size.times
        .each do |index|
          line = lines[index]

          parse_line(index, line)
        end
    end

    private

    def parse_line(index, line)
      statements = []

      if line.match? VMTranslator::Commands::PUSH_REGEX
        inner_match = line.match(VMTranslator::Commands::PUSH_REGEX)[1].to_s

        ram, value = parse_line(index, inner_match)

        statements.concat ram.pop(value)
        statements.concat stack.push(value)
      elsif line.match? VMTranslator::Commands::POP_REGEX
        inner_match = line.match(VMTranslator::Commands::POP_REGEX)[1].to_s

        ram, value = parse_line(index, inner_match)

        statements.concat stack.pop(value)
        statements.concat ram.push(value)
      elsif line.match? VMTranslator::Commands::CONSTANT_REGEX
        value = line.match(VMTranslator::Commands::CONSTANT_REGEX)[1].to_i

        [constant_ram, value]
      elsif line.match? VMTranslator::Commands::LOCAL_REGEX
        value = line.match(VMTranslator::Commands::LOCAL_REGEX)[1].to_i

        [local_ram, value]
      elsif line.match? VMTranslator::Commands::ARGUMENT_REGEX
        value = line.match(VMTranslator::Commands::ARGUMENT_REGEX)[1].to_i

        [argument_ram, value]
      elsif line.match? VMTranslator::Commands::THIS_REGEX
        value = line.match(VMTranslator::Commands::THIS_REGEX)[1].to_i

        [this_ram, value]
      elsif line.match? VMTranslator::Commands::THAT_REGEX
        value = line.match(VMTranslator::Commands::THAT_REGEX)[1].to_i

        [that_ram, value]
      elsif line.match? VMTranslator::Commands::TEMP_REGEX
        value = line.match(VMTranslator::Commands::TEMP_REGEX)[1].to_i

        [temp_ram, value]
      elsif line.match? VMTranslator::Commands::POINTER_REGEX
        value = line.match(VMTranslator::Commands::POINTER_REGEX)[1].to_i

        [pointer_ram, value]
      elsif line.match? VMTranslator::Commands::STATIC_REGEX
        value = line.match(VMTranslator::Commands::STATIC_REGEX)[1].to_i

        [static_ram, value]
      elsif line.match? VMTranslator::Commands::ADD_REGEX
        statements.concat stack.add
      elsif line.match? VMTranslator::Commands::SUB_REGEX
        statements.concat stack.sub
      elsif line.match? VMTranslator::Commands::EQ_REGEX
        statements.concat stack.eq
      elsif line.match? VMTranslator::Commands::LT_REGEX
        statements.concat stack.lt
      elsif line.match? VMTranslator::Commands::GT_REGEX
        statements.concat stack.gt
      elsif line.match? VMTranslator::Commands::NEG_REGEX
        statements.concat stack.neg
      elsif line.match? VMTranslator::Commands::AND_REGEX
        statements.concat stack.asm_reset_to_one

        statements.concat stack.pop(0)
        statements.concat stack.and_operation

        statements.concat stack.pop(0)
        statements.concat stack.and_operation

        statements.concat stack.push(0)
      elsif line.match? VMTranslator::Commands::OR_REGEX
        statements.concat stack.asm_reset_to_zero

        statements.concat stack.pop(0)
        statements.concat stack.or_operation

        statements.concat stack.pop(0)
        statements.concat stack.or_operation

        statements.concat stack.push(0)
      elsif line.match? VMTranslator::Commands::NOT_REGEX
        statements.concat stack.not
      elsif line.match? VMTranslator::Commands::LABEL_REGEX
        label_name = line.match(VMTranslator::Commands::LABEL_REGEX)[1].to_s

        statements.concat stack.add_label(label_name, program_counter)
      elsif line.match? VMTranslator::Commands::GO_TO_NOW_REGEX
        label_name = line.match(VMTranslator::Commands::GO_TO_NOW_REGEX)[1].to_s

        statements.concat stack.go_to_now(label_name)
      elsif line.match? VMTranslator::Commands::GO_TO_IF_REGEX
        label_name = line.match(VMTranslator::Commands::GO_TO_IF_REGEX)[1].to_s

        statements.concat stack.pop(0)
        statements.concat stack.go_to_if(label_name, argument_ram)
      elsif line.match? VMTranslator::Commands::FUNCTION_REGEX
        name = line.match(VMTranslator::Commands::FUNCTION_REGEX)[1].to_s
        local_ram_total = line.match(VMTranslator::Commands::FUNCTION_REGEX)[2].to_i

        # Assumptions:
        # 1. Function is only defined once
        # 2. Function _always_ accepts the same amount of arguments
        function =
          if @functions.key? name
            @functions[name]
          else
            VMTranslator::Function.new(name)
          end

        function.local_total = local_ram_total

        statements << function.label
      elsif line.match? VMTranslator::Commands::CALL_REGEX
        name = line.match(VMTranslator::Commands::CALL_REGEX)[1].to_s
        argument_total = line.match(VMTranslator::Commands::CALL_REGEX)[2].to_i

        # Assumptions:
        # 1. Function is only defined once
        # 2. Function _always_ accepts the same amount of arguments
        function =
          if @functions.key? name
            @functions[name]
          else
            VMTranslator::Function.new(name)
          end

        function.argument_total = argument_total

        # Reserve RAM for the Function's return value
        if argument_total.zero?
          constant_ram.pop(0)
          stack.push(0)
        end

        # Push the current stack address (i.e., the Program Counter)
        # Into the Stack
        constant_ram.pop(@program_counter)
        stack.push(0)

        ram_objects = [
          local_ram,
          argument_ram,
          this_ram,
          that_ram
        ]

        # Push the locations of RAM into the Stack
        ram_objects.each do |ram_object|
          ram_object.value

          stack.push(0)
        end

        function.execute
      elsif line.match? VMTranslator::Commands::RETURN_REGEX
        statements.concat stack.pop(0)
        statements.concat argument_ram.push(0)
        statements.concat argument_ram.value
        statements.concat temp_ram.push(0)

        restore_rams = [
          that_ram,
          this_ram,
          argument_ram,
          local_ram
        ]

        # Restore the RAMs and the Stack
        restore_rams.each do |ram_memory|
          statements.concat stack.pop(0)
          statements.concat stack.dereferenced_value

          statements.concat ram_memory.set_value_to_d_register
        end

        stack.pop(0)
        stack.go_to_now(stack.value)

        # Add +1 to ARG and store in Stack value
        statements.concat temp_ram.pop(0)
        statements.concat stack.push(0)

        statements.concat constant_ram.pop(1)
        statements.concat stack.push(0)

        statements.concat stack.asm_reset_to_zero
        statements.concat stack.pop(0)
        statements.concat stack.add_operation

        statements.concat stack.pop(0)
        statements.concat stack.add_operation

        statements.concat stack.set_value_to_d_register
      end
    ensure
      print(statements)
    end

    def print(statements)
      statements = Array(statements).map(&:strip)

      statements.size.times.each do |index|
        statement = statements[index]

        is_empty = false
        is_empty = true if statement.empty?
        is_empty = true if statement.start_with? '//'

        puts "// PC: #{program_counter}" unless is_empty
        puts statement

        @program_counter += 1 unless is_empty
      end
    end

    attr_reader :lines, :stack
    attr_reader :constant_ram, :local_ram, :argument_ram, :this_ram, :that_ram, :temp_ram, :pointer_ram, :static_ram
  end
end
