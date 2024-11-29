# frozen_string_literal: true

module VMTranslator
  class Stack < RAM
    attr_reader :vm_stack

    def address_local
      STACK_ADDRESS_LOCATION
    end

    def initialize
      super

      @labels = {}
      @vm_stack = VMStack.new
      @go_to_counter = 0
    end

    def pop(_value)
      pop = <<~POP
        // Decrement the Stack
        @#{address_local}
        M=M-1
      POP
      puts pop.chomp
      puts

      vm_stack.pop
    end

    def push(value)
      command = <<~COMMAND
        // Set Stack to the D Register
        @#{address_local}
        A=M
        M=D
      COMMAND
      puts command.chomp
      puts
      vm_stack.push(value)

      increment_stack = <<~COMMAND
        @#{address_local}
        M=M+1
      COMMAND
      puts increment_stack.chomp
      puts

      increment_go_to_counter
    end

    def eq
      asm_binary_operation('JEQ') do |first_value, second_value|
        result =
          if second_value < first_value
            -1
          else
            0
          end

        push(result)
      end
    end

    def lt
      asm_binary_operation('JLT') do |first_value, second_value|
        result =
          if second_value < first_value
            -1
          else
            0
          end

        push(result)
      end
    end

    def gt
      asm_binary_operation('JGT') do |first_value, second_value|
        result =
          if second_value < first_value
            -1
          else
            0
          end

        push(result)
      end
    end

    def and
      reset_to_one = <<~RESET
        D=-1
      RESET
      puts reset_to_one.chomp
      puts

      first_value = pop(0)
      puts and_operation.chomp
      puts

      second_value = pop(0)
      puts and_operation.chomp
      puts

      push(first_value & second_value)
    end

    def or
      puts asm_reset_to_zero
      puts

      first_value = pop(0)
      puts or_operation.chomp
      puts

      second_value = pop(0)
      puts or_operation.chomp
      puts

      push(first_value | second_value)
    end

    def neg
      value = pop(0)
      operation = <<~NEGATE
        @0
        D=A-D
      NEGATE
      puts operation.chomp
      puts

      result = 0 - value
      push(result)
    end

    def not
      value = pop(0)
      operation = <<~NEGATE
        @0
        D=!D
      NEGATE
      puts operation.chomp
      puts

      result = ~value
      push(result)
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
    end

    def asm_binary_operation(operator, &block)
      puts asm_reset_to_zero
      puts

      first_value = pop(0)
      puts sub_operation
      puts

      second_value = pop(0)
      puts sub_operation
      puts

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

      block.call(first_value, second_value)
    end

    def asm_operation_result(binary_operator_type)
      execute = <<~EQUALITY
        @#{go_to_if_true}
        D;#{binary_operator_type}

        D=0
        @#{go_to_end}
        0;JMP

        (#{go_to_if_true})
        D=-1
        (#{go_to_end})
      EQUALITY

      execute.chomp
    end

    def asm_reset_to_zero
      reset_to_zero = <<~RESET
        D=0
      RESET

      puts reset_to_zero.chomp
      puts
    end

    def asm_reset_to_one
      reset_to_one = <<~RESET
        D=-1
      RESET
      puts reset_to_one.chomp
      puts
    end

    def add_label(name, program_counter)
      labels[name] = program_counter.to_i

      label_statement = <<~LABEL
        (#{name})
      LABEL

      puts label_statement.chomp
    end

    def if_go_to(name, ram)
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

    attr_reader :go_to_counter, :labels
  end
end
