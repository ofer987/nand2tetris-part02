# frozen_string_literal: true

module JackCompiler
  class ExecutionExpression
    class << self
      def execution_node?(xml_node)
        evaluation_node = Utils::XML.find_child_nodes_with_css_selector(
          xml_node,
          "> #{Statement::EVALUATION_TYPE_STATEMENT}"
        ).first

        return false if evaluation_node.blank?

        evaluation_node.text == Statement::EXECUTION_TYPE
      end
    end

    attr_reader :object, :method, :symbol, :expression_list_node

    def initialize(xml_node, variable:)
      @xml_node = xml_node
      @variable = variable

      @object, @method = Utils::XML.find_child_nodes_with_css_selector(
        xml_node,
        "> #{Statement::TERM_STATEMENT} > #{Statement::IDENTIFIER}"
      )[0..1]
        .map(&:text)
        .map(&:strip)

      self.expression_list_node = "> #{Statement::TERM_STATEMENT} > #{Statement::EXPRESSION_LIST}"

      @symbol = Utils::XML.find_child_nodes_with_css_selector(xml_node, "> #{Statement::SYMBOL}")
        .map(&:text)
        .map(&:strip)
        .first

      variable.value = Memory::NULL_VALUE
    end

    def emit_vm_code(memory_scope)
      return '' if expression_list_node.blank?

      <<~VM_CODE
        // Set up the "this" segment
        push pointer 0

        // Not required: Pop arguments
        // push Arguments
        #{expression_list_node.emit_vm_code(memory_scope)}

        call #{object}.#{method} #{expression_list_node.size}

        // TODO: Method should pop the pointer into local variable
        // TODO: Both Functions/Methods should pop the stack into argument variables
        #{variable.assign_value_from_stack}

        // Reconfigure the caller's _this_ and its arguments will be automatically reconfigured
        push temp 0
        pop pointer 0
        push this 0
      VM_CODE
    end

    def calculate(objects); end

    private

    def expression_list_node=(css_selector)
      xml_nodes = Array(Utils::XML.find_child_nodes_with_css_selector(xml_node, css_selector))

      @expression_list_node = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node) }
        .first
    end

    attr_reader :xml_node, :variable, :memory_scope
  end
end
