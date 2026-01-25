# frozen_string_literal: true

module JackCompiler
  class Memory
    def self.next_static_memory_index
      unless defined? @next_static_memory_index
        @next_static_memory_index = 16

        return @next_static_memory_index
      end

      if @next_static_memory_index >= MAX_STATIC_MEMORY
        raise "Failed to allocate static memory at #{@next_static_memory_index + 1}, " \
          'because static memory can only be allocated within the range 16 to 255'
      end

      @next_static_memory_index += 1
    end

    MAX_STATIC_MEMORY = 255

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

    def initialize(type:, name:, index:, kind:)
      @type = type
      @name = name
      @index = index
      @kind = kind
    end

    def assignment_vm_code(_options = {})
      raise NotImplementedError
    end
  end
end
