# frozen_string_literal: true

module JackCompiler
  class InfixEvaluatorAssignmentExpression
    class << self
      def execution_node?(xml_node)
        evaluation_node = Utils::XML.find_child_nodes_with_css_selector(
          xml_node,
          "> #{Statement::EVALUATION_TYPE_STATEMENT}"
        ).first

        return false if evaluation_node.blank?

        evaluation_node.text == Statement::INFIX_EXPRESSION
      end
    end

    attr_reader :value

    def initialize(xml_node, variable:, offset:)
      @xml_node = xml_node
      @variable = variable
      @offset = offset

      self.value = "> #{Statement::EVALUATION_STATEMENT}"
    end

    def calculate(objects)
      calculator = PostfixCalculator.new(expression: value)

      variable.value = calculator.calculate(memory: objects)
    end

    def emit_vm_code(objects)
      calculator = PostfixCalculator.new(expression: value)

      result = calculator.emit_vm_code(memory: objects)
      result << variable.assign_value_from_stack(offset: offset)

      result.join("\n")
    end

    private

    def characters
      @characters ||= value.chars
    end

    def value=(css_selector)
      infix_value = Utils::XML.find_child_nodes_with_css_selector(xml_node, css_selector)
        .map(&:text)
        .map(&:strip)
        .first

      @value = Utils::Infix.to_postfix(infix_value)
    end

    attr_reader :xml_node, :variable, :offset
  end
end
