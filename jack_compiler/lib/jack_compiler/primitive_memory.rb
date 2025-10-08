# frozen_string_literal: true

module JackCompiler
  class PrimitiveMemory < Memory
    attr_reader :name, :memory_class, :index, :location
    attr_accessor :value

    def type
      PRIMITIVE
    end

    def initialize(name:, memory_class:, index:, location:)
      super(name:, memory_class:)

      @index = index
      @location = location
    end

    def emit_vm_code
      ''
    end
  end
end
