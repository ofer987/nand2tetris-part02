# frozen_string_literal: true

module VMTranslator
  class Stack < RAM
    def self.pop(negative_offset_index)
      pop = <<~COMMAND
        // Negative Offset index of #{negative_offset_index}
        @#{negative_offset_index}
        D=A

        // Store the value of RAM[#{STACK_ADDRESS_LOCATION}] into the D Register
        #{STACK_ADDRESS_LOCATION}
        D=M-D
      COMMAND

      puts pop.chomp
      puts

      count_lines(pop)
    end

    def self.push
      push = <<~COMMAND
        // Store the value of the D Register into RAM[#{STACK_ADDRESS_LOCATION}]
        @#{STACK_ADDRESS_LOCATION}
        M=D
      COMMAND

      puts push.chomp
      puts

      count_lines(push)
    end

    def address_local
      STACK_ADDRESS_LOCATION
    end

    def initialize
      super

      @labels = {}
      @go_to_counter = 0
      @function_counter = 0
    end

    def pop(_value)
      pop = <<~POP
        // Decrement the Stack
        @#{address_local}
        M=M-1
      POP
      puts pop.chomp
      puts

      count_lines(pop)
    end

    def push(_indexed_address)
      command = <<~COMMAND
        // Set Stack to the D Register
        @#{address_local}
        A=M
        M=D
      COMMAND
      puts command.chomp
      puts

      increment_stack = <<~COMMAND
        @#{address_local}
        M=M+1
      COMMAND
      puts increment_stack.chomp
      puts

      increment_go_to_counter

      count_lines("#{command}\n#{increment_stack}")
    end

    def eq
      asm_binary_operation('JEQ')
    end

    def lt
      asm_binary_operation('JLT')
    end

    def gt
      asm_binary_operation('JGT')
    end

    def and
      reset_to_one = <<~RESET
        D=-1
      RESET
      puts reset_to_one.chomp
      puts
      result = count_lines(reset_to_one)

      result += pop(0)
      result += and_operation

      result += pop(0)
      result += and_operation

      result += push(0)

      result
    end

    def or
      result = asm_reset_to_zero

      result += pop(0)
      result += or_operation

      result += pop(0)
      result += or_operation

      result += push(0)

      result
    end

    def neg
      result = pop(0)
      operation = <<~NEGATE
        @0
        D=A-D
      NEGATE
      puts operation.chomp
      puts
      result += count_lines(operation)

      result += push(0)

      result
    end

    def not
      result = pop(0)
      operation = <<~NEGATE
        @0
        D=!D
      NEGATE
      puts operation.chomp
      puts
      result += count_lines(operation)

      result += push(0)

      result
    end

    def add_operation
      result = <<~VALUE
        @#{address_local}
        A=M

        // Add
        D=M+D
      VALUE

      puts result.chomp
      puts

      count_lines(result)
    end

    def sub_operation
      result = <<~VALUE
        @#{address_local}
        A=M

        // Sub
        D=M-D
      VALUE

      puts result.chomp
      puts

      count_lines(result)
    end

    def and_operation
      result = <<~VALUE
        @#{address_local}
        A=M

        // And
        D=M&D
      VALUE

      puts result.chomp
      puts

      count_lines(result)
    end

    def or_operation
      result = <<~VALUE
        @#{address_local}
        A=M

        // Or
        D=M|D
      VALUE

      puts result.chomp
      puts

      count_lines(result)
    end

    def asm_binary_operation(operator)
      result = asm_reset_to_zero

      result += pop(0)
      result += sub_operation

      result += pop(0)
      result += sub_operation

      execute = <<~EQUALITY
        @#{go_to_if_true}
        D;#{operator}

        D=0
        @#{go_to_end}
        0;JMP

        (#{go_to_if_true})
        D=-1
        (#{go_to_end})
      EQUALITY
      puts execute.chomp
      puts
      result += count_lines(execute)

      result += push(0)

      result
    end

    # def asm_operation_result(binary_operator_type)
    #   execute = <<~EQUALITY
    #     @#{go_to_if_true}
    #     D;#{binary_operator_type}
    #
    #     D=0
    #     @#{go_to_end}
    #     0;JMP
    #
    #     (#{go_to_if_true})
    #     D=-1
    #     (#{go_to_end})
    #   EQUALITY
    #
    #   execute.chomp
    # end

    def asm_reset_to_zero
      reset_to_zero = <<~RESET
        D=0
      RESET

      puts reset_to_zero.chomp
      puts

      count_lines(reset_to_zero)
    end

    def asm_reset_to_one
      reset_to_one = <<~RESET
        D=-1
      RESET
      puts reset_to_one.chomp
      puts

      count_lines(reset_to_one)
    end

    def add_label(name, program_counter)
      labels[name] = program_counter.to_i

      label_statement = <<~LABEL
        (#{name})
      LABEL

      puts label_statement.chomp

      count_lines(label_statement)
    end

    def go_to_now(name)
      go_to_statement = <<~COMMAND
        @#{name}
        0;JMP
      COMMAND

      puts go_to_statement.chomp
      puts

      count_lines(go_to_now)
    end

    def go_to_if(name, ram)
      go_to_statement = <<~COMMAND
        // The D Register stores the value
        @#{ram.address_local}
        A=M
        D=M

        @#{name}
        D;JGT
      COMMAND

      puts go_to_statement.chomp
      puts

      count_lines(go_to_statement)
    end

    def call_function(function)
      call_statements = <<~COMMAND
        @#{name}
        0;JMP

        (#{function.return_label})
      COMMAND

      function.increment_return_counter

      puts call_statements.chomp
      puts

      count_lines(call_statements)
    end

    private

    def go_to
      @go_to ||= 'GO_TO'
    end

    def go_to_if_true
      "#{go_to}_if_true_#{go_to_counter}"
    end

    def go_to_end
      "#{go_to}_end_#{go_to_counter}"
    end

    def increment_go_to_counter
      @go_to_counter += 1
    end

    def increment_function_counter
      @function_counter += 1
    end

    attr_reader :go_to_counter, :labels, :function_counter
  end
end
