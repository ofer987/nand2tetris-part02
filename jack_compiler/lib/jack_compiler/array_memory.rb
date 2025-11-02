# frozen_string_literal: true

module JackCompiler
  class ArrayMemory < Memory
    attr_reader :name, :index, :type, :kind
    attr_accessor :value

    def memory_type
      ARRAY
    end

    def initialize(name:, type:, index:, kind:)
      super(name:, type:, index:, kind:)

      @value = Memory::NULL_VALUE
    end

    def assignment_vm_code(options = {})
      <<~VM_CODE
        pop temp 0
        push constant #{options[:offset]}
        push #{kind} #{index}
        add

        pop pointer 1
        push temp 0

        pop that 0
      VM_CODE
    end

    def emit_vm_code
      ''
    end
  end
end
