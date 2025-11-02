# frozen_string_literal: true

module JackCompiler
  class ClassMemory < Memory
    attr_reader :name, :index, :type, :kind
    attr_accessor :value

    def memory_type
      CLASS
    end

    def initialize(name:, type:, index:, kind:)
      super(name:, type:, index:, kind:)

      @value = Memory::NULL_VALUE
    end

    def assignment_vm_code(_options = {})
      <<~VM_CODE
        pop #{kind} #{index}
      VM_CODE
    end
  end
end
