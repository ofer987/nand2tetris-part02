# frozen_string_literal: true

class Stack
  STACK_ADDRESS_LOCATION = 0
  STACK_START_RAM_INDEX = 256

  def ram_index
    STACK_START_RAM_INDEX + index
  end

  def initialize
    # binding.pry
    @index = 0
    @array = []
  end

  def push(value)
    array << value

    # binding.pry
    self.index += 1
  end

  def add(first_value, second_value)
    push(second_value + first_value)
  end

  def sub(first_value, second_value)
    push(second_value - first_value)
  end

  def equal(first_value, second_value)
    is_equal_in_boolean =
      if second_value == first_value
        -1
      else
        0
      end
    push(is_equal_in_boolean)
  end

  def less_than(first_value, second_value)
    is_equal_in_boolean =
      if second_value < first_value
        -1
      else
        0
      end

    push(is_equal_in_boolean)
  end

  def greater_than
    is_equal_in_boolean =
      if second_value > first_value
        -1
      else
        0
      end
    push(is_equal_in_boolean)
  end

  def pop
    self.index -= 1
    value = array.pop

    raise "cannot pop index below #{STACK_START_RAM_INDEX}" if index.negative?

    value
  end

  private

  attr_reader :array
  attr_accessor :index
end
