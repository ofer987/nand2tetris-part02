# frozen_string_literal: true

module JackCompiler
  class ArrayMemory < Memory
    attr_reader :type, :name, :kind
    attr_accessor :value, :index

    def initialize(type:, name:, kind:, index: 0)
      super(type:, name:, index:, kind:)

      @value = Memory::NULL_VALUE
    end

    def assignment_vm_code(options = {})
      <<~VM_CODE
        push constant #{options[:offset]}
        push #{kind} #{index}
        add
        pop pointer 1
        pop that 0
      VM_CODE
    end

    def assign_value_from_stack
      <<~MEMORY_SCOPE
        pop temp 0
        pop pointer 1
        push temp 0
        pop that 0
      MEMORY_SCOPE
    end

    def emit_vm_code
      ''
    end
  end
end
