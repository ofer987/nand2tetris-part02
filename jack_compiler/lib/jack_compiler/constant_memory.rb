# frozen_string_literal: true

module JackCompiler
  class ConstantMemory < Memory
    attr_reader :type, :name, :kind
    attr_accessor :value, :index

    # values are
    # String
    # Array
    # int
    # and other classes
    # def type
    # end

    # rubocop:disable Lint/UnusedMethodArgument
    def initialize(value:, index: 0, type: Type::CONSTANT, name: '', kind: Kind::NOT_APPLICABLE)
      super(type: Type::CONSTANT, name: '', index: 0, kind: Kind::NOT_APPLICABLE)

      @value = value
    end
    # rubocop:enable Lint/UnusedMethodArgument

    def read_memory
      "push constant #{value}"
    end

    def assign_value(_memory_value)
      <<~MEMORY_SCOPE
        pop temp 0
      MEMORY_SCOPE
    end

    def assignment_vm_code(_options = {})
      <<~VM_CODE
        pop #{kind} #{index}
      VM_CODE
    end
  end
end
