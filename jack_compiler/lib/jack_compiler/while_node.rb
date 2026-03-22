# frozen_string_literal: true

module JackCompiler
  class WhileNode < Node
    NODE_NAME = Statement::WHILE_STATEMENT

    def initialize(xml_node, options)
      super(xml_node, options)

      # TODO: enable
      self.condition = " > #{Statement::EXPRESSION_STATEMENT} > #{Statement::EVALUATION_STATEMENT}"
      self.statement_nodes = STATEMENT_NODES_CSS_SELECTOR
    end

    def emit_vm_code
      <<~VM_CODE
        label #{start_loop_label}
          #{condition.emit_vm_code}
        if-goto #{if_true_label}
        goto #{end_loop_label}
        label #{if_true_label}
          #{statement_nodes.map(&:emit_vm_code).join("\n")}
        goto #{start_loop_label}
        label #{end_loop_label}
      VM_CODE
    end

    private

    def condition=(css_selector)
      # value = find_child_nodes_with_css_selector(css_selector).first.text
      value = find_child_nodes_with_css_selector(css_selector)
      text = value.first.text

      @condition = BooleanExpression.new(text, memory_scope)
    end

    def statement_nodes=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @statement_nodes = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node, memory_scope:) }
    end

    def get_conditional_statements(conditional_statement, css_selector)
      return [] unless else_statements_exist?

      conditional_statement.css(css_selector)
        .map { |node| Utils::XML.convert_to_jack_node(node, options) }
    end

    def start_loop_label
      @start_loop_label ||= "START_LOOP_#{uuid}"
    end

    def if_true_label
      @if_true_label ||= "IF_TRUE_#{uuid}"
    end

    def end_loop_label
      @end_loop_label ||= "END_LOOP_#{uuid}"
    end

    def uuid
      @uuid ||= SecureRandom.uuid
    end

    attr_reader :condition, :if_statements, :else_statements, :memory, :statement_nodes
  end
end
