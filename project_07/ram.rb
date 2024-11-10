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
      @#{stack.ram_index}
      M=D

      @#{stack.ram_index}
      D=A

      @#{Stack::STACK_ADDRESS_LOCATION}
      M=D
    COMMAND

    puts command.chomp

    # binding.pry
    stack.push(value)
  end

  def pop
    pop = <<~POP
      @#{stack.ram_index}
      D=D+M

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

    first_value = pop
    second_value = pop

    push(first_value + second_value)
  end
end
