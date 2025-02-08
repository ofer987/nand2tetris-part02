# frozen_string_literal: true

require_relative 'jack_compiler/version'
require_relative 'jack_compiler/regular_expressions'
require_relative 'jack_compiler/state_machine'

require 'active_support'
require 'active_support/core_ext'
require 'nokogiri'

module JackCompiler
  class Error < StandardError; end
  # Your code goes here...
end
