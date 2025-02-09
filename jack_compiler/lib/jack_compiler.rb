# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'
require 'nokogiri'

require_relative 'jack_compiler/regular_expressions'

require_relative 'jack_compiler/statement'
require_relative 'jack_compiler/open_brace_statement'
require_relative 'jack_compiler/close_brace_statement'
require_relative 'jack_compiler/class_statement'
require_relative 'jack_compiler/let_statement'
require_relative 'jack_compiler/if_statement'

require_relative 'jack_compiler/version'
require_relative 'jack_compiler/state_machine'

module JackCompiler
  class Error < StandardError; end
  # Your code goes here...
end
