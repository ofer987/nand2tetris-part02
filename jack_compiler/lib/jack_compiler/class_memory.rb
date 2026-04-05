# frozen_string_literal: true

module JackCompiler
  class ClassMemory < Memory
    attr_reader :type, :name, :kind
    attr_accessor :value, :index

    def initialize(type:, name:, kind:, index: 0)
      super(type:, name:, index:, kind:)

      @value = Memory::NULL_VALUE
    end

    def assignment_vm_code(*)
      <<~VM_CODE
        pop this 0
      VM_CODE
    end

    def prepare_memory(*)
      <<~VM_CODE
        #{read_memory}
        pop pointer 0
      VM_CODE
    end
  end
end
