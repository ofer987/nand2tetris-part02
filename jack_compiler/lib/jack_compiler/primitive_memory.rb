# frozen_string_literal: true

module JackCompiler
  class PrimitiveMemory < Memory
    attr_reader :name, :type, :kind
    attr_accessor :value, :index

    # TODO: rename to kind
    # Where values are
    # this for class field
    # static (for class field)
    # local for function/method
    # argument for function/method
    def memory_type
      PRIMITIVE
    end

    # values are
    # String
    # Array
    # int
    # and other classes
    # def type
    # end

    def initialize(name:, type:,  kind:, index: 0)
      super(name:, type:, index:, kind:)

      @value = 0
    end

    def assignment_vm_code(_options = {})
      <<~VM_CODE
        pop #{kind} #{index}
      VM_CODE
    end
  end
end
