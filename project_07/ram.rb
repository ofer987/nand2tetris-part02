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

    increment_go_to_counter
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

    increment_go_to_counter
    push(second_value - first_value)
  end

  # Return -1 if True
  # return 0  if False
  def eq
    reset_to_zero = <<~RESET
      D=0
    RESET
    puts reset_to_zero.chomp

    first_value = decrement_stack
    operation = <<~EQUALITY
      @#{Stack::STACK_ADDRESS_LOCATION}
      D=M-D
    EQUALITY
    puts operation.chomp

    second_value = decrement_stack
    puts operation.chomp

    is_equal = <<~EQUALITY
      @#{go_to_if_true}
      D;JEQ

      D=0
      @#{go_to_end}

      (#{go_to_if_true})
      D=-1
      (#{go_to_end})
    EQUALITY

    puts is_equal.chomp
    is_equal_in_boolean =
      if second_value == first_value
        -1
      else
        0
      end
    push(is_equal_in_boolean)

    increment_go_to_counter
  end

  # Return -1 if True
  # return 0  if False
  def lt
    reset_to_zero = <<~RESET
      D=0
    RESET
    puts reset_to_zero.chomp

    first_value = decrement_stack
    operation = <<~EQUALITY
      @#{Stack::STACK_ADDRESS_LOCATION}
      D=M-D
    EQUALITY
    puts operation.chomp

    second_value = decrement_stack
    puts operation.chomp

    is_lt = <<~EQUALITY
      @#{go_to_if_true}
      D;JLT

      D=0
      @#{go_to_end}

      (#{go_to_if_true})
      D=-1
      (#{go_to_end})
    EQUALITY

    puts is_lt.chomp
    is_equal_in_boolean =
      if second_value < first_value
        -1
      else
        0
      end
    push(is_equal_in_boolean)

    increment_go_to_counter
  end

  # Return -1 if True
  # return 0  if False
  def gt
    reset_to_zero = <<~RESET
      D=0
    RESET
    puts reset_to_zero.chomp

    first_value = decrement_stack
    operation = <<~EQUALITY
      @#{Stack::STACK_ADDRESS_LOCATION}
      D=M-D
    EQUALITY
    puts operation.chomp

    second_value = decrement_stack
    puts operation.chomp

    is_gt = <<~EQUALITY
      @#{go_to_if_true}
      D;JGT

      D=0
      @#{go_to_end}

      (#{go_to_if_true})
      D=-1
      (#{go_to_end})
    EQUALITY

    puts is_gt.chomp
    is_equal_in_boolean =
      if second_value > first_value
        -1
      else
        0
      end
    push(is_equal_in_boolean)

    increment_go_to_counter
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

    increment_go_to_counter
  end

  def or
    reset_to_zero = <<~RESET
      D=0
    RESET
    puts reset_to_zero.chomp

    first_value = decrement_stack
    puts or_operation.chomp

    second_value = decrement_stack
    puts or_operation.chomp

    push(first_value | second_value)

    increment_go_to_counter
  end

  def neg
    pre_operation = <<~NEGATE
      @0
      D=A
    NEGATE
    puts pre_operation.chomp

    value = decrement_stack

    operation = <<~NEGATE
      D=D-M
    NEGATE
    puts operation.chomp

    result = 0 - value
    push(result)

    increment_go_to_counter
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

  def and_operation
    result = <<~VALUE
      @#{Stack::STACK_ADDRESS_LOCATION}
      A=M

      D=D&M
    VALUE

    result.chomp
  end

  def or_operation
    result = <<~VALUE
      @#{Stack::STACK_ADDRESS_LOCATION}
      A=M

      D=D|M
    VALUE

    result.chomp
  end
end
