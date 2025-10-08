# frozen_string_literal: true

module JackCompiler
  class Memory
    CLASS = 'class'
    PRIMITIVE = 'primitive'

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

    def emit_vm_code
      raise NotImplementedError
    end
  end
end
