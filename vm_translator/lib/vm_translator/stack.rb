# frozen_string_literal: true

module VMTranslator
  class Stack < RAM
    def address
      STACK_ADDRESS_LOCATION
    end

    def initialize
      super

      @labels = {}
      @go_to_counter = 0
      @function_counter = 0
    end

    def pop(_value)
      statements = []

      pop = <<~POP
        // Decrement the Stack
        @#{address}
        M=M-1
      POP
      statements.concat pop.split("\n")
      statements << "\n"

      statements
    end

    def push(_indexed_address)
      statements = []

      command = <<~COMMAND
        // Set Stack to the D Register
        @#{address}
        A=M
        M=D
      COMMAND
      statements.concat command.split("\n")
      statements << "\n"

      increment_stack = <<~COMMAND
        @#{address}
        M=M+1
      COMMAND
      statements.concat increment_stack.split("\n")
      statements << "\n"

      increment_go_to_counter

      statements
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

    def neg
      statements = []

      statements.concat pop(0)
      operation = <<~NEGATE
        @0
        D=A-D
      NEGATE
      statements.concat operation.split("\n")
      statements << "\n"

      statements.concat push(0)

      statements
    end

    def not
      statements = []

      statements.concat pop(0)
      operation = <<~NEGATE
        @0
        D=!D
      NEGATE
      statements.concat operation.split("\n")
      statements << "\n"

      statements.concat push(0)

      statements
    end

    def add
      statements = []

      statements.concat asm_reset_to_zero

      statements.concat pop(0)
      statements.concat add_operation

      statements.concat pop(0)
      statements.concat add_operation

      statements.concat push(0)

      statements
    end

    def add_operation
      statements = []

      result = <<~VALUE
        @#{address}
        A=M

        // Add
        D=M+D
      VALUE

      statements.concat result.split("\n")
      statements << "\n"

      statements
    end

    def sub
      statements = []

      statements.concat asm_reset_to_zero

      statements.concat pop(0)
      statements.concat sub_operation

      statements.concat pop(0)
      statements.concat sub_operation

      statements.concat push(0)
    end

    def sub_operation
      statements = []

      result = <<~VALUE
        @#{address}
        A=M

        // Sub
        D=M-D
      VALUE

      statements.concat result.split("\n")
      statements << "\n"

      statements
    end

    def and_operation
      statements = []

      result = <<~VALUE
        @#{address}
        A=M

        // And
        D=M&D
      VALUE

      statements.concat result.split("\n")
      statements << "\n"

      statements
    end

    def or_operation
      statements = []

      result = <<~VALUE
        @#{address}
        A=M

        // Or
        D=M|D
      VALUE

      statements.concat result.split("\n")
      statements << "\n"

      statements
    end

    def asm_binary_operation(operator)
      statements = []

      statements.concat asm_reset_to_zero

      statements.concat pop(0)
      statements.concat sub_operation

      statements.concat pop(0)
      statements.concat sub_operation

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
      statements.concat execute.split("\n")
      statements << "\n"

      statements.concat push(0)

      statements
    end

    def asm_reset_to_zero
      statements = []

      reset_to_zero = <<~RESET
        D=0
      RESET

      statements.concat reset_to_zero.split("\n")
      statements << "\n"

      statements
    end

    def asm_reset_to_one
      statements = []

      reset_to_one = <<~RESET
        D=-1
      RESET

      statements.concat reset_to_one.split("\n")
      statements << "\n"

      statements
    end

    def add_label(name, program_counter)
      statements = []

      labels[name] = program_counter.to_i

      label_statement = <<~LABEL
        (#{name})
      LABEL

      statements.concat label_statement.split("\n")

      statements
    end

    def return
      statements = []

      go_to_statement = <<~COMMAND
        // Return
        @#{address}
        A=M
        A=M
        0;JMP
      COMMAND

      statements.concat go_to_statement.split("\n")
      statements << "\n"

      statements
    end

    def go_to_now(name)
      statements = []

      go_to_statement = <<~COMMAND
        @#{name}
        0;JMP
      COMMAND

      statements.concat go_to_statement.split("\n")
      statements << "\n"

      statements
    end

    def go_to_if(name, ram)
      statements = []

      go_to_statement = <<~COMMAND
        // The D Register stores the value
        @#{ram.address}
        A=M
        D=M

        @#{name}
        D;JGT
      COMMAND

      statements.concat go_to_statement.split("\n")
      statements << "\n"

      statements
    end

    def call_function(function)
      call_statements = <<~COMMAND
        @#{name}
        0;JMP

        (#{function.return_label})
      COMMAND

      function.increment_return_counter

      puts call_statements.chomp
      statements << "\n"
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
