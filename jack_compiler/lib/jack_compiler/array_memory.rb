# frozen_string_literal: true

module JackCompiler
  class ArrayMemory < Memory
    attr_reader :type, :name, :kind
    attr_accessor :value, :index

    def initialize(type:, name:, kind:, index: 0)
      super(type:, name:, index:, kind:)

      @value = Memory::NULL_VALUE
    end

    def assignment_vm_code(offset:)
      return "pop #{kind} #{index}" if offset.nil?

      'pop that 0'
    end

    def prepare_memory(memory_scope:, offset:)
      # Behave like a primitive
      # i.e., just store the memory address
      return if offset.nil?

      result = []
      if offset.match?(/\d+/)
        result << "push constant #{offset}"
      else
        raise "Cannot find field variable '#{offset}'" unless memory_scope.key? offset

        offset_variable = memory_scope[offset]
        result << "push #{offset_variable.kind} #{offset_variable.index}"
      end

      result << read_memory
      result << 'add'
      result << 'pop pointer 1'

      result.join("\n")
    end

    def emit_vm_code
      ''
    end
  end
end
