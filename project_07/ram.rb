# frozen_string_literal: true

class RAM
  attr_reader :stack

  def initialize
    @stack = Stack.new
    @go_to_counter = 0
  end

  def constant(integer)
    value = <<~CONSTANT
      @#{integer}
      D=A
    CONSTANT

    puts value.chomp
    integer
  end

  def push(value)
    command = <<~COMMAND
      @#{Stack::STACK_ADDRESS_LOCATION}
      A=M

      // Set RAM to value
      M=D
    COMMAND
    puts command.chomp
    stack.push(value)

    increment_stack = <<~COMMAND
      @#{Stack::STACK_ADDRESS_LOCATION}
      M=M+1
    COMMAND
    puts increment_stack.chomp

    increment_go_to_counter
  end

  def decrement_stack
    pop = <<~POP
      // Decrement the Stack
      @#{Stack::STACK_ADDRESS_LOCATION}
      M=M-1
    POP
    puts pop.chomp

    stack.pop
  end

  def add
    reset_to_zero = <<~RESET
      D=0
    RESET
    puts reset_to_zero.chomp

    first_value = decrement_stack
    puts add_operation.chomp

    second_value = decrement_stack
    puts add_operation.chomp

    push(first_value + second_value)
  end

  def sub
    reset_to_zero = <<~RESET
      D=0
    RESET
    puts reset_to_zero.chomp

    first_value = decrement_stack
    puts sub_operation.chomp

    second_value = decrement_stack
    puts sub_operation.chomp

    push(second_value - first_value)
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

    first_value = decrement_stack
    puts and_operation.chomp

    second_value = decrement_stack
    puts and_operation.chomp

    push(first_value & second_value)
  end

  def or
    puts asm_reset_to_zero

    first_value = decrement_stack
    puts or_operation.chomp

    second_value = decrement_stack
    puts or_operation.chomp

    push(first_value | second_value)
  end

  def neg
    value = decrement_stack
    operation = <<~NEGATE
      @0
      D=A-D
    NEGATE
    puts operation.chomp

    result = 0 - value
    push(result)
  end

  def not
    value = decrement_stack
    operation = <<~NEGATE
      @0
      D=!D
    NEGATE
    puts operation.chomp

    result = ~value
    push(result)
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

  def add_operation
    result = <<~VALUE
      @#{Stack::STACK_ADDRESS_LOCATION}
      A=M

      // Add
      D=M+D
    VALUE

    result.chomp
  end

  def sub_operation
    result = <<~VALUE
      @#{Stack::STACK_ADDRESS_LOCATION}
      A=M

      // Sub
      D=M-D
    VALUE

    result.chomp
  end

  def and_operation
    result = <<~VALUE
      @#{Stack::STACK_ADDRESS_LOCATION}
      A=M

      // And
      D=M&D
    VALUE

    result.chomp
  end

  def or_operation
    result = <<~VALUE
      @#{Stack::STACK_ADDRESS_LOCATION}
      A=M

      // Or
      D=M|D
    VALUE

    result.chomp
  end

  def asm_binary_operation(operator, &block)
    puts asm_reset_to_zero

    first_value = decrement_stack
    puts sub_operation

    second_value = decrement_stack
    puts sub_operation

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

    reset_to_zero.chomp
  end

  attr_reader :go_to_counter
end
