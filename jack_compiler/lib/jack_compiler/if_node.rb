# frozen_string_literal: true

module JackCompiler
  class IfNode < Node
    NODE_NAME = Statement::IF_STATEMENT

    def initialize(xml_node, options)
      super(xml_node, options)

      if_statement, else_statement = find_child_nodes_with_css_selector("> #{Statement::STATEMENTS_STATEMENT}")[0..1]
      # TODO: enable
      self.condition = " > #{Statement::EXPRESSION_STATEMENT} > #{Statement::EVALUATION_STATEMENT}"

      # rubocop:disable Layout/LineLength
      @if_statements = get_conditional_statements(if_statement, "#{Statement::LET_STATEMENT}, #{Statement::DO_STATEMENT}, #{Statement::IF_STATEMENT}")
      @else_statements = get_conditional_statements(else_statement, "#{Statement::LET_STATEMENT}, #{Statement::DO_STATEMENT}, #{Statement::IF_STATEMENT}") if else_statements_exist?
      # rubocop:enable Layout/LineLength
    end

    def emit_vm_code
      <<~VM_CODE
        #{condition.emit_vm_code(options[:scope])}
        if-goto #{if_true_label}
        goto #{if_false_label}
        label #{if_true_label}
          #{if_statements.map(&:emit_vm_code).join("\n")}
        goto #{if_end_label}
        label #{if_false_label}
          #{else_statements.map(&:emit_vm_code).join("\n")}
        label #{if_end_label}
      VM_CODE
    end

    private

    def condition=(css_selector)
      value = find_child_nodes_with_css_selector(css_selector).first.text

      @condition = BooleanExpression.new(value)
    end

    def get_conditional_statements(conditional_statement, css_selector)
      return [] unless else_statements_exist?

      conditional_statement.css(css_selector)
        .map { |node| Utils::XML.convert_to_jack_node(node, options) }
    end

    def else_statements_exist?
      @else_statements_exist ||= find_child_nodes(Statement::KEYWORD)
        .map(&:text)
        .map(&:strip)
        .select { |text| text == Statement::ELSE_STATEMENT }
        .any?
    end

    def if_true_label
      @if_true_label ||= "IF_TRUE_#{uuid}"
    end

    def if_end_label
      @if_end_label ||= "IF_END_#{uuid}"
    end

    def if_false_label
      @if_false_label ||= "IF_FALSE_#{uuid}"
    end

    def uuid
      @uuid ||= SecureRandom.uuid
    end

    attr_reader :condition, :if_statements, :else_statements, :memory
  end
end
