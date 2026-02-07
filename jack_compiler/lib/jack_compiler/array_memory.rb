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
        // Pop current value of array into temp
        // pop that 0
        // push pointer 1
        // pop temp 0

        // Assume the result has already been placed on the Stack
        // Now set the "that"'s memory address
        push constant #{options[:offset]}
        push #{kind} #{index}
        add
        pop pointer 1

        // And push the results into the Array directly via "that"'s memory address
        pop that 0
      VM_CODE
    end

    def emit_vm_code
      ''
    end
  end
end
