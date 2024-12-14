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
        argument_total = line.match(VMTranslator::Commands::FUNCTION_REGEX)[2].to_i + 1

        function = VMTranslator::Function.new(name, lines[index..])
        if @functions.key? function.name
          puts "Error: #{function.name} has already been defined"

          exit 1
        end

        @functions[function.name] = function
        # function_size = @functions.size
        # function.allocate_ram(@last_function_end_address_space_index, argument_total)

        statements << function.label
        # statements.concat function.initialize_local_ram(stack, local_ram)
        # statements.concat function.initialize_argument_ram(stack, argument_ram, argument_total)
        # statements.concat function.initialize_this_ram(constant_ram)
        # statements.concat function.initialize_that_ram(constant_ram)
        #
        # statements.concat stack.reset_pointer_by_offset(function.local_total + function.argument_total)

        # TODO: review this
        # statements.concat function.body_statements

        # @last_function_end_address_space_index = function.end_ram_address_space_index

        # local_total = function.initialize_local_ram(stack, @last_function_end_address_space_index + 1)
        # function.create_local_ram

        # Store RAM state on the stack
        # ram_classes = [
        #   VMTranslator::Stack,
        #   VMTranslator::Local,
        #   VMTranslator::Argument,
        #   VMTranslator::This,
        #   VMTranslator::That
        # ]

        # ram_classes.each do |klazz|
        #   klazz.pop
        #
        #   stack.push
        # end

        # Now, allocate RAM for the function
        # Ignore the Stack RAM
        # index = 0

        # ram_size = ram_classes[1..].size
        # ram_classes[1..].each do |klazz|
        #   constant_ram.pop(((function_size * ram_size) + index) * 1000)
        #   klazz.push
        #
        #   index += 1
        # end
        # function.initialize
        #
        # stack.push
        # function.generate_argument_ram(function_size)
        #
        # stack.declare_function(function_name, argument_total, local_total)
      elsif line.match? VMTranslator::Commands::CALL_REGEX
        function_name = line.match(VMTranslator::Commands::CALL_REGEX)[1].to_s
        # argument_total = line.match(VMTranslator::Commands::CALL_REGEX)[2].to_i

        function = @functions[function_name]
        if function.nil?
          puts "The function #{function_name} has not been defined yet"

          exit 1
        end

        # Push the current stack address (i.e., the Program Counter)
        # Into the Stack
        constant_ram.pop(@program_counter)
        stack.push(0)

        ram_classes = [
          VMTranslator::Local,
          VMTranslator::Argument,
          VMTranslator::This,
          VMTranslator::That
        ]

        # Push the locations of RAM into the Stack
        ram_classes.each do |klazz|
          klazz.pop

          stack.push(0)
        end

        function.execute

        # Allocate Local, Argument, This, and That here
        # function.allocate_ram(VMTranslator::Stack.pop, argument_total)

        # VMTranslator::Stack.pop
        # @local_ram = function.initialize_local_ram
        # @argument_ram = function.initialize_argument_ram(stack, argument_total)
        # @this_ram = function.initialize_this_ram
        # @that_ram = function.initialize_that_ram

        # Store the Stack, and RAM into the stack
        # ram_classes = [
        #   VMTranslator::Stack,
        #   VMTranslator::Local,
        #   VMTranslator::Argument,
        #   VMTranslator::This,
        #   VMTranslator::That
        # ]
        #
        # ram_classes.each do |klazz|
        #   klazz.pop
        #
        #   stack.push
        # end

        # stack.call_function(function_name, function.label)

        # Store the return value in the Stack

        # Store the return value into the temp
        stack.pop
        temp_ram.push(0)
        # stack.reset_pointer_to_d_register
        # local_ram.push
        # argument_ram.push

        # Reset the Stack to Local's address
        VMTranslator::Local.pop
        stack.reset_pointer_to_d_register
        # stack.reset_pointer_by_offset(5)
        # stack.pop
        # stack.push
        # VMTranslator::Argument

        # VMTranslator::Stack.push

        # stack.reset_pointer_to_d_register
        restore_ram_classes = [
          VMTranslator::That,
          VMTranslator::This,
          VMTranslator::Argument,
          VMTranslator::Local,
          VMTranslator::Stack
        ]

        # Restore the RAMs and the Stack
        stack.pop(0)
        restore_ram_classes.each do |klazz|
          stack.pop(0)

          klazz.push
        end

        # The Stack should now be pointing to the Return Address

        # Push (i.e., store) the current address in Temp 1
        stack.pop(0)
        temp_ram.push(1)

        stack.pop(0)
        argument_ram.push(0)

        temp_ram.pop(1)
        stack.push(0)
      elsif line.match? VMTranslator::Commands::RETURN_REGEX
        # binding.pry
        statements.concat stack.pop(0)
        statements.concat argument_ram.push(0)
        statements.concat argument_ram.value
        statements.concat temp_ram.push(0)
        # stack.reset_pointer_to_d_register
        # local_ram.push
        # argument_ram.push

        # Reset the Stack to Local's address
        # statements.concat VMTranslator::Local.pop
        # statements.concat stack.reset_pointer_to_d_register
        # stack.reset_pointer_by_offset(5)
        # stack.pop
        # stack.push
        # VMTranslator::Argument

        # VMTranslator::Stack.push

        # stack.reset_pointer_to_d_register

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

        # statements.concat temp_ram.pop(0)
        # statements.concat stack.set_value_to_d_register

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
