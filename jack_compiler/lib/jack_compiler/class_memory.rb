# frozen_string_literal: true

module JackCompiler
  class ClassMemory < Memory
    attr_reader :type, :name, :kind
    attr_accessor :value, :index

    def initialize(type:, name:, kind:, index: 0)
      super(type:, name:, index:, kind:)

      @value = Memory::NULL_VALUE
    end

    def callee_constructor_vm_code
      # TODO: move constructor to its own Ruby code
      <<~VM_CODE
        // TODO: Pop arguments
        // TODO: Call alloc
        push #{arguments.size}
        Memory.alloc 1
        pop pointer 0
        // Set up the "this" segment
        call #{type}.new

        // TODO: When accessing argument memory:
        // TODO: Push "argument" memory into the stack; and then
        // TODO: Pop into the "this" #{location of field memory} or location of method local memory or location of static memory

        push pointer 0
        return
      VM_CODE
    end

    def caller_constructor_vm_code
      # TODO: move to its own Ruby code
      <<~VM_CODE
        // TODO: Push arguments
        call #{type}.new
        pop #{kind} #{index}
      VM_CODE
    end

    def assignment_vm_code(_options = {})
      binding.pry
      <<~VM_CODE
        // Pop variable on stack into the "this" segment
        pop pointer 0
      VM_CODE
    end
  end
end
