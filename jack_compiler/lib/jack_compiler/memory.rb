# frozen_string_literal: true

module JackCompiler
  class Memory
    TEMPORARY_MEMORY = 'temp 0'

    def self.next_static_memory_index
      unless defined? @next_static_memory_index
        @next_static_memory_index = 0

        return @next_static_memory_index
      end

      if @next_static_memory_index >= MAX_STATIC_MEMORY
        raise "Failed to allocate static memory at #{@next_static_memory_index + 1}, " \
          'because static memory can only be allocated within the range 16 to 255'
      end

      @next_static_memory_index += 1
    end

    # Or is it 255?
    MAX_STATIC_MEMORY = 255 - 16

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
      return Location::STATIC if kind == Kind::STATIC

      raise "Memory Location could not be found for Type '#{type}' and Kind '#{kind}'"
    end

    def prepare_memory(*); end

    def finish_prepare_memory(*); end

    def read_memory
      "push #{kind} #{index}"
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
      @kind = kind
      @index = index

      @index = Memory.next_static_memory_index if self.kind == Kind::STATIC
    end

    def assignment_vm_code(*)
      raise NotImplementedError
    end
  end
end
