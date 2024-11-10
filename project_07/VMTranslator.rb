#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './stack'
require_relative './ram'

require 'pry-byebug'

CONSTANT_REGEX = /constant (\d+)/
PUSH_REGEX = /^push (.+)$/
ADD_REGEX = /^add$/

ram = RAM.new
path = ARGV[0].to_s

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

File.readlines(path)
  .map(&:chomp)
  .each { |line| parse(ram, line) }

exit 0
