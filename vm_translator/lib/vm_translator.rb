# frozen_string_literal: true

require_relative 'vm_translator/version'
require_relative './vm_translator/vm_stack'
require_relative './vm_translator/ram'
require_relative './vm_translator/stack'
require_relative './vm_translator/constant'
require_relative './vm_translator/local'
require_relative './vm_translator/argument'
require_relative './vm_translator/this'
require_relative './vm_translator/that'
require_relative './vm_translator/temp'
require_relative './vm_translator/pointer'
require_relative './vm_translator/static'
require_relative './vm_translator/commands'
require_relative './vm_translator/parser'
require_relative './vm_translator/function'
require_relative './vm_translator/klazz'

module VMTranslator
  class Error < StandardError; end
end
