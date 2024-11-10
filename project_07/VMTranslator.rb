#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './stack'
require_relative './ram'

CONSTANT_REGEX = /constant (\d+)/
PUSH_REGEX = /^push (.+)$/
ADD_REGEX = /^add$/

ram = RAM.new
path = ARGV[0].to_s

def put_start_program
  output = <<~START_PROGRAM
    (START)
    @#{Stack::STACK_START_RAM_INDEX}
    D=A

    @#{Stack::STACK_ADDRESS_LOCATION}
    M=D
  START_PROGRAM

  puts output.chomp
end

def put_end_program
  output = <<~END_PROGRAM
    (END)

    @END
    0;JMP
  END_PROGRAM

  puts output.chomp
end

def parse(ram, line)
  if line.match? PUSH_REGEX
    inner_match = line.match(PUSH_REGEX)[1].to_s

    value = parse(ram, inner_match)
    ram.push(value)
  elsif line.match? CONSTANT_REGEX
    result = line.match(CONSTANT_REGEX)[1].to_i

    ram.constant(result)
  elsif line.match? ADD_REGEX
    ram.add
  end
end

begin
  put_start_program

  File.readlines(path)
    .map(&:chomp)
    .each { |line| parse(ram, line) }

  put_end_program
rescue StandardError => e
  puts "Error converting VM to ASM: #{e}"

  exit 1
end

exit 0
