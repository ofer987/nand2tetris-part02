# frozen_string_literal: true

require_relative 'vm_translator/version'
require_relative './vm_translator/vm_stack'
require_relative './vm_translator/ram'
require_relative './vm_translator/stack'
require_relative './vm_translator/constant'

module VMTranslator
  class Error < StandardError; end
  # Your code goes here...
end
