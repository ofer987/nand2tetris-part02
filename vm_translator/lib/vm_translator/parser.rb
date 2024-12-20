#!/usr/bin/env ruby
# frozen_string_literal: true

module VMTranslator
  class Parser
    PROGRAM_COUNTER_SHIFT = 98

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
      @function_return_stack = []
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

      parse_functions

      lines.size.times
        .each do |index|
          line = lines[index]

          parse_line(index, line)
        end
    end

    private

    def parse_functions
      lines.each do |line|
        parse_function(line)
      end
    end

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

        function = @functions[name]
        raise "Could not find Function (#{name})" if function.nil?

        statements << function.label
        statements << "// Preparing Local variables for Function #{function.name}"

        # Add Local variables on to the Stack
        # statements << "// Add #{function.local_total} to LOCAL RAM"
        # statements.concat stack.value
        # statements.concat stack.push(0)
        #
        # statements.concat constant_ram.pop(function.local_total)
        # statements.concat stack.push(0)
        # statements.concat stack.add
        # statements.concat stack.set_value_to_d_register
        statements.concat function.initialize_local_ram(function.local_total)

        # binding.pry
      elsif line.match? VMTranslator::Commands::CALL_REGEX
        name = line.match(VMTranslator::Commands::CALL_REGEX)[1].to_s
        argument_total = line.match(VMTranslator::Commands::CALL_REGEX)[2].to_i
        function = @functions[name]
        raise "Could not find Function (#{name})" if function.nil?

        # Debug
        statements << "// Preparing Function #{function.name} before calling it"

        # Push the current stack address (i.e., the Program Counter)
        # Into the Stack
        statements.concat << "// Add Program Counter to ARGUMENT_RAM @ #{@program_counter} + #{PROGRAM_COUNTER_SHIFT}"
        statements.concat constant_ram.pop(@program_counter)
        statements.concat stack.push(0)

        statements.concat constant_ram.pop(PROGRAM_COUNTER_SHIFT)
        statements.concat stack.push(0)
        statements.concat stack.add

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

        # Remove argument_total from argument_ram.value
        statements << '// Setting ARGUMENT_RAM'
        statements.concat stack.value
        statements.concat stack.push(0)

        statements.concat constant_ram.pop(argument_total + 4 + 1)
        statements.concat stack.push(0)
        statements.concat stack.sub

        statements.concat stack.pop(0)
        statements.concat argument_ram.set_value_to_d_register

        # Set new LOCAL RAM Address
        statements.concat stack.value
        statements.concat local_ram.set_value_to_d_register

        statements << "// Finished Preparing Function #{function.name}: Now calling it"
        statements.concat function.execute

        function.increment_return_counter
        return_label = function.return_label
        statements << "(#{return_label})"

        increment_stack = <<~COMMAND
          // Retrieve the Return Value
          @#{VMTranslator::RAM::STACK_ADDRESS_LOCATION}
          M=M+1

          A=M
          D=M

          @#{VMTranslator::RAM::STACK_ADDRESS_LOCATION}
          // TODO: remove this later
          // M=M-1
          M=M-1

          // Place the Return Value on the Stack Pointer
          A=M
          M=D

          @#{VMTranslator::RAM::STACK_ADDRESS_LOCATION}
          M=M+1
        COMMAND

        statements.concat increment_stack.split("\n")
        statements << "\n"
      elsif line.match? VMTranslator::Commands::RETURN_REGEX
        function = find_function(name, index)
        raise 'Cannot return because we are not in a Function' if function.nil?

        statements << "// Returning from #{function.name}"

        # statements << '// Reset the Stack to current value - LOCAL_RAM count of caller'
        statements.concat function.reset_stack_pointer_to_argument_second_approach

        statements << '// Restore SP to address of LOCAL_RAM'
        statements.concat local_ram.value
        statements.concat stack.set_value_to_d_register

        restore_rams = [
          that_ram,
          this_ram,
          argument_ram,
          local_ram
        ]

        # Restore the RAMs and the Stack
        statements << '// Restore the Memories'
        restore_rams.each do |ram_memory|
          statements << "// Restore #{ram_memory.class}"
          statements.concat stack.pop(0)
          statements.concat stack.dereferenced_value

          statements.concat ram_memory.set_value_to_d_register
        end

        statements << "// Retrieve the Return Value @ (4 + #{function.local_total} + #{function.argument_total})"
        statements << "// But first decrement the stack by #{function.argument_total}"
        statements.concat stack.value
        statements.concat stack.push(0)

        statements.concat constant_ram.pop(function.argument_total)
        statements.concat stack.push(0)
        statements.concat stack.sub
        statements.concat stack.set_value_to_d_register

        statements.concat stack.value
        statements.concat stack.push(0)
        statements.concat constant_ram.pop(4 + function.local_total + function.argument_total)
        statements.concat stack.push(0)
        statements.concat stack.asm_reset_to_zero
        statements.concat stack.pop(0)
        statements.concat stack.add_operation

        statements.concat stack.pop(0)
        statements.concat stack.add_operation
        statements.concat stack.push(0)
        statements.concat stack.pop(0)
        statements.concat stack.de_dereferenced_value
        statements.concat stack.push(0)
        statements.concat stack.pop(0)
        statements.concat stack.pop(0)

        go_to_statement = <<~COMMAND
          // Return to the caller, i.e., #{function.name}
          @#{VMTranslator::RAM::STACK_ADDRESS_LOCATION}
          A=M
          A=M
          0;JMP
        COMMAND

        statements.concat go_to_statement.split("\n")
        statements << "\n"
      end
    ensure
      print(statements)
    end

    def find_function(name, current_vm_line_index)
      (current_vm_line_index + 1).times.each do |index|
        line_index = current_vm_line_index - index
        line = lines[line_index]

        next unless line.match? VMTranslator::Commands::FUNCTION_REGEX

        name = line.match(VMTranslator::Commands::FUNCTION_REGEX)[1].to_s
        return @functions[name]
      end
    end

    def parse_function(line)
      if line.match? VMTranslator::Commands::FUNCTION_REGEX
        name = line.match(VMTranslator::Commands::FUNCTION_REGEX)[1].to_s
        local_ram_total = line.match(VMTranslator::Commands::FUNCTION_REGEX)[2].to_i

        # Assumptions:
        # 1. Function is only defined once
        # 2. Function _always_ accepts the same amount of arguments
        function = nil
        if @functions.key? name
          function = @functions[name]
        else
          function = VMTranslator::Function.new(name)
          @functions[name] = function
        end

        function.local_total = local_ram_total
      elsif line.match? VMTranslator::Commands::CALL_REGEX
        name = line.match(VMTranslator::Commands::CALL_REGEX)[1].to_s
        argument_total = line.match(VMTranslator::Commands::CALL_REGEX)[2].to_i

        # Assumptions:
        # 1. Function is only defined once
        # 2. Function _always_ accepts the same amount of arguments
        function = nil
        if @functions.key? name
          function = @functions[name]
        else
          function = VMTranslator::Function.new(name)
          @functions[name] = function
        end

        function.argument_total = argument_total
      end
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
