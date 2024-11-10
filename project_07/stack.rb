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

  def pop
    value = array.pop

    raise "cannot pop index below #{STACK_START_RAM_INDEX}" if index.negative?

    # binding.pry
    self.index -= 1

    value
  end

  private

  attr_reader :array
  attr_accessor :index
end
