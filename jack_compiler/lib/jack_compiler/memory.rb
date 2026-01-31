# frozen_string_literal: true

module JackCompiler
  class Memory
    # attr_reader :type, :name, :kind, :value, :index

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
      CONSTANT = 'constant'
    end

    # Four types of scope
    module Kind
      LOCAL = 'local'
      ARGUMENT = 'argument'
      FIELD = 'field'
      STATIC = 'static'
      NOT_APPLICABLE = 'NA'
    end

    module Location
      LOCAL = 'local'
      CONSTANT = 'constant'
      STATIC = 'static'
      OBJECT = 'this'
      ARRAY = 'that'
      ARGUMENT = 'argument'
    end

    NULL_VALUE = 0
    EMPTY_CLASS = 'classless'

    def memory_location
      return Location::CONSTANT if type == Location::CONSTANT
      return Location::LOCAL if kind == Kind::LOCAL
      return Location::ARGUMENT if kind == Kind::ARGUMENT
      return Location::OBJECT if kind == Kind::FIELD

      raise "Memory Location could not be found for Type '#{type}' and Kind '#{kind}'"
    end

    def read_memory
      "push #{memory_location} #{index}"
    end

    def assign_value(memory_value)
      <<~MEMORY_SCOPE
        #{memory_value.read_memory}
        pop #{memory_location} #{index}
      MEMORY_SCOPE
    end

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
