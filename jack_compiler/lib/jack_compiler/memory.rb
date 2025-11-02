# frozen_string_literal: true

module JackCompiler
  class Memory
    ARRAY = 'array'
    CLASS = 'class'
    PRIMITIVE = 'primitive'

    EMPTY_CLASS = 'classless'

    def name
      raise NotImplementedError
    end

    def memory_class
      raise NotImplementedError
    end

    def type
      NotImplementedError
    end

    def location
      NotImplementedError
    end

    def index
      raise NotImplementedError
    end

    def value
      raise NotImplementedError
    end

    def initialize(name:, memory_class:)
      @name = name
      @memory_class = memory_class
    end

    def assignment_vm_code(_options = {})
      raise NotImplementedError
    end
  end
end
