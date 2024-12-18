#!/usr/bin/env ruby
# frozen_string_literal: true

module VMTranslator
  class Parser
    attr_reader :program_counter

    def put_start_program
      vm_statements = []
      output = <<~PROGRAM_START
        call Sys.init 0
      PROGRAM_START

      vm_statements.concat output.split("\n")
      vm_statements.concat << "\n"

      vm_statements
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
      @function_stack = []
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

    def parse(init: false)
      if init
        start_vm_lines = put_start_program
        start_vm_lines.size.times
          .each do |index|
            line = start_vm_lines[index]

            parse_line(index, line)
          end
      end

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

        puts "// Preparing Local variables for Function #{function.name}"

        function.local_total = local_ram_total

        statements << function.label

        # Add Local variables on to the Stack
        puts "// Add #{function.local_total} to LOCAL RAM"
        statements.concat stack.value
        statements.concat stack.push(0)

        statements.concat constant_ram.pop(function.local_total)
        statements.concat stack.push(0)
        statements.concat stack.add
        statements.concat stack.set_value_to_d_register
        statements.concat function.initialize_local_ram(local_ram, temp_ram)

        @function_stack << function
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

        # NOTE: This might be a bug!
        function.argument_total = argument_total

        # Increment the local_ram value by current function local ram total
        current_function = @function_stack[-1]
        current_function_local_ram_total = current_function.local_total

        # Debug
        puts "// Preparing Function #{current_function.name} before calling it"

        # Reserve RAM for the Function's return value
        statements.concat stack.value
        statements.concat temp_ram.push(0)

        # statements.concat stack.push(0)
        # statements.concat constant_ram.pop(current_function_local_ram_total)
        # statements.concat stack.push(0)
        #
        # statements.concat stack.add
        # statements.concat stack.set_value_to_d_register

        # statements.concat stack.pop(0)
        # statements.concat stack.add_operation
        #
        # statements.concat stack.pop(0)
        # statements.concat stack.add_operation

        # Stack is now local_ram + current_function's local ram total
        # Argument RAM is now local_ram + current_function's local ram total

        # Add the number of (arguments - 1) to the Stack
        # statements.concat stack.value
        # statements.concat stack.push(0)
        #
        # statements.concat constant_ram.pop(function.argument_total - 1)
        # statements.concat stack.push(0)
        #
        # statements.concat stack.pop(0)
        # statements.concat stack.add_operation
        #
        # statements.concat stack.pop(0)
        # statements.concat stack.add_operation
        #
        # statements.concat stack.set_value_to_d_register

        # Space for the function's return argument
        # statements.concat stack.pop(0)
        # if argument_total.zero?
        #   statements.concat constant_ram.pop(1)
        #   statements.concat stack.push(0)
        # end

        # Push the current stack address (i.e., the Program Counter)
        # Into the Stack
        statements.concat constant_ram.pop(@program_counter)
        statements.concat stack.push(0)

        ram_objects = [
          local_ram,
          argument_ram,
          this_ram,
          that_ram
        ]

        # Push the locations of RAM into the Stack
        ram_objects.each do |ram_object|
          statements.concat ram_object.value

          statements.concat stack.push(0)
        end

        # Argument will be current argument + 4  + function argument - 1 + function local
        # NOTE
        # statements.concat temp_ram.pop(0)
        # statements.concat argument_ram.set_value_to_d_register

        # Remove argument_total from argument_ram.value
        statements.concat temp_ram.pop(0)
        statements.concat stack.push(0)

        statements.concat constant_ram.pop(argument_total)
        statements.concat stack.push(0)
        statements.concat stack.sub

        statements.concat stack.pop(0)
        statements.concat argument_ram.set_value_to_d_register
        # statements.concat local_ram.set_value_to_d_register

        # Set new LOCAL RAM Address
        statements.concat stack.value
        statements.concat local_ram.set_value_to_d_register

        @function_stack << function

        puts "// Finished Preparing Function #{current_function.name}: Now calling it"
        statements.concat function.execute
      elsif line.match? VMTranslator::Commands::RETURN_REGEX
        raise "#{VMTranslator::Commands::RETURN_REGEX} should be placed within a function" if @function_stack.empty?

        current_function = @function_stack.pop
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

        statements.concat argument_ram.reference
        statements.concat stack.return

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
        is_empty = true if statement.match?(/^\(.*\)$/)

        puts "// PC: #{program_counter}" unless is_empty
        puts statement

        @program_counter += 1 unless is_empty
      end
    end

    attr_reader :lines, :stack
    attr_reader :constant_ram, :local_ram, :argument_ram, :this_ram, :that_ram, :temp_ram, :pointer_ram, :static_ram
  end
end
