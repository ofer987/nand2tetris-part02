# frozen_string_literal: true

module JackCompiler
  class StringAssignmentExpressionNode < Node
    NODE_NAME = ''
    REGEX = RegularExpressions::STRING_CONSTANT_ASSIGNMENT

    attr_reader :value

    def initialize(xml_node, memory_index:)
      super(xml_node, {})

      @memory_index = memory_index
      self.value = "> #{Statement::EXPRESSION_STATEMENT} > #{Statement::TERM_STATEMENT} > #{Statement::STRING_CONSTANT}"
    end

    def emit_vm_code
      characters.map do |character|
        <<~VM_CODE
          call String.appendChar #{memory_index}
          push constant #{character.ord}
        VM_CODE
      end
      "push constant #{value}"
    end

    private

    def characters
      @characters ||= value.chars
    end

    def value=(css_selector)
      @value = find_child_nodes_with_css_selector(css_selector)
        .map(&:text)
        .first
    end
  end
end
