# frozen_string_literal: true

class RAM
  attr_reader :stack

  def initialize
    @stack = Stack.new
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
    # binding.pry

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
  end

  def decrement_stack
    pop = <<~POP
      // Decrement the stack
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

  private

  def add_operation
    result = <<~VALUE
      @#{Stack::STACK_ADDRESS_LOCATION}
      A=M

      D=D+M
    VALUE

    result.chomp
  end

  def sub_operation
    result = <<~VALUE
      @#{Stack::STACK_ADDRESS_LOCATION}
      A=M

      D=D-M
    VALUE

    result.chomp
  end
end
