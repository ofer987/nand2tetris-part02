# frozen_string_literal: true

module JackCompiler
  class Memory
    # Three types of memory
    module Type
      ARRAY = 'array'
      CLASS = 'class'
      PRIMITIVE = 'primitive'
    end

    # Four types of scope
    module Kind
      LOCAL = 'local'
      ARGUMENT = 'argument'
      FIELD = 'field'
      STATIC = 'static'
    end

    NULL_VALUE = 0
    EMPTY_CLASS = 'classless'

    def name
      raise NotImplementedError
    end

    def type
      raise NotImplementedError
    end

    def kind
      NotImplementedError
    end

    def index
      raise NotImplementedError
    end

    def value
      raise NotImplementedError
    end

    def initialize(name:, index:, kind:)
      @name = name
      @index = index
      @kind = kind
    end

    def assignment_vm_code(_options = {})
      raise NotImplementedError
    end
  end
end
