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

    def prepare_memory(memory_scope:, offset:)
      # Behave like a primitive
      # i.e., just store the memory address
      return if offset.blank?
      raise "Cannot find field variable '#{offset}' in class '#{type}'" unless memory_scope.key? offset

      variable = memory_scope[variable]
      unless variable.kind == Memory::Kind::FIELD
        raise "Variable '#{offset}' is not a #{Memory::Kind::FIELD} variable in class '#{type}'" 
      end

      vm_code = []

      vm_code << read_memory
      vm_code << "push #{variable.kind} #{variable.index}"
      vm_code << 'add'

      vm_code << 'pop pointer 0'

      vm_code.join("\n")
    end
  end
end
