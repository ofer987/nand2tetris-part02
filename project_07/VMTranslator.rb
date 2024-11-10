#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry-byebug'

CONSTANT_REGEX = /constant (\d+)/
PUSH_REGEX = /^push (.+)$/
ADD_REGEX = /^add$/

# STACK_ADDRESS_LOCATION = 0
#
# STACK_START_LOCATION = 256
# STACK_SHIFT_INDEX = 0

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
    @index += 1
  end

  def pop
    value = array.pop

    raise "cannot pop index below #{STACK_START_RAM_INDEX}" if index.negative?

    # binding.pry
    @index -= 1

    value
  end

  private

  attr_reader :array
  attr_accessor :index
end

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

# def constant(integer)
#   value = <<~CONSTANT
#     @#{integer}
#     D=A
#   CONSTANT
#
#   puts value.chomp
# end
#
# def push(value)
#   # binding.pry
#
#   command = <<~COMMAND
#     @#{STACK.ram_index}
#     M=D
#
#     @#{STACK.ram_index}
#     D=A
#
#     @#{Stack::STACK_ADDRESS_LOCATION}
#     M=D
#   COMMAND
#
#   puts command.chomp
#
#   binding.pry
#   STACK << value
# end
#
# def pop
#   pop = <<~POP
#     @#{stack_index}
#     D=D+M
#
#     @#{STACK_ADDRESS_LOCATION}
#     M=M-1
#   POP
#
#   puts pop.chomp
#
#   STACK.pop
# end
#
# def add
#   reset_to_zero = <<~RESET
#     D=0
#   RESET
#
#   puts reset_to_zero.chomp
#
#   first_value = pop
#   second_value = pop
#
#   push(first_value + second_value)
# end

ram = RAM.new
path = ARGV[0].to_s
# stack = Stack.new

def parse(ram, line)
  if line.match? PUSH_REGEX
    inner_match = line.match(PUSH_REGEX)[1].to_s

    value = parse(ram, inner_match)
    # binding.pry
    ram.push(value)
  elsif line.match? CONSTANT_REGEX
    result = line.match(CONSTANT_REGEX)[1].to_i

    ram.constant(result)
  elsif line.match? ADD_REGEX
    ram.add
  end
end

File.readlines(path).each do |line|
  parse(ram, line)
end

exit 0
