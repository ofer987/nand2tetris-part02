# frozen_string_literal: true

module JackCompiler
  class ArrayMemory < Memory
    attr_reader :name, :index, :location
    attr_accessor :value

    def type
      ARRAY
    end

    def memory_class
      EMPTY_CLASS
    end

    def initialize(name:, memory_class:, index:, location:)
      super(name:, memory_class:)

      @index = index
      @location = location
      @value = 0
    end

    def assignment_vm_code(options = {})
      <<~VM_CODE
        pop temp 0
        push constant #{options[:offset]}
        push #{location} #{index}
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
