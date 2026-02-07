# frozen_string_literal: true

module JackCompiler
  class PrimitiveMemory < Memory
    attr_reader :type, :name, :kind
    attr_accessor :index, :value

    # values are
    # String
    # Array
    # int
    # and other classes
    # def type
    # end

    def initialize(type:, name:, kind:, index: 0)
      super(type:, name:, index:, kind:)

      @value = 0
    end

    def read_memory
      "push #{memory_location} #{index}"
    end

    def assignment_vm_code(_options = {})
      <<~VM_CODE
        pop #{kind} #{index}
      VM_CODE
    end
  end
end
