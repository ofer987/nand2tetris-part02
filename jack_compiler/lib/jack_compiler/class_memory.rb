# frozen_string_literal: true

module JackCompiler
  class ClassMemory < Memory
    attr_reader :name, :type, :kind
    attr_accessor :value, :index

    def memory_type
      CLASS
    end

    def initialize(name:, type:,  kind:, index: 0)
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
