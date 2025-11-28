# frozen_string_literal: true

module JackCompiler
  class Memory
    ARRAY = 'array'
    CLASS = 'class'
    PRIMITIVE = 'primitive'

    NULL_VALUE = 0
    EMPTY_CLASS = 'classless'

    module Kind
      LOCAL = 'local'
      STATIC = 'static'
      FIELD = 'field'
      ARGUMENT = 'argument'
    end

    def name
      raise NotImplementedError
    end

    def memory_type
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

    def initialize(name:, type:, index:, kind:)
      @name = name
      @type = type
      @index = index
      @kind = kind
    end

    def assignment_vm_code(_options = {})
      raise NotImplementedError
    end
  end
end
