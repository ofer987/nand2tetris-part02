# frozen_string_literal: true

module JackCompiler
  class StringAssignmentExpression
    class << self
      def execution_node?(xml_node, memory:)
        return false if memory.type != Memory::CLASS

        evaluation_node = Utils::XML.find_child_nodes_with_css_selector(
          xml_node,
          "> #{Statement::EVALUATION_TYPE_STATEMENT}"
        ).first

        return false if evaluation_node.blank?

        evaluation_node.text == Statement::STRING_CONSTANT
      end
    end

    attr_reader :value

    def initialize(xml_node, memory:)
      @xml_node = xml_node
      @memory = memory

      self.value = "> #{Statement::TERM_STATEMENT} > #{Statement::STRING_CONSTANT}"
      memory.value = value
    end

    def emit_vm_code(_objects)
      result = []
      characters.each do |character|
        result << <<~VM_CODE
          call String.appendChar #{memory.index}
          push constant #{character.ord}
        VM_CODE
      end

      result << "push constant #{value}"

      result
        .join("\n")
    end

    def calculate(objects); end

    private

    def characters
      @characters ||= value.chars
    end

    def value=(css_selector)
      @value = Utils::XML.find_child_nodes_with_css_selector(xml_node, css_selector)
        .map(&:text)
        .map(&:strip)
        .first
    end

    attr_reader :xml_node, :memory
  end
end
