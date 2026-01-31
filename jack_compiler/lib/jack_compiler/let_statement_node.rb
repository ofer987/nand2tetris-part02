# frozen_string_literal: true

module JackCompiler
  class LetStatementNode < StatementNode
    REGEX = ''
    NODE_NAME = Statement::LET_STATEMENT

    attr_reader :variable, :expression_node

    def initialize(xml_node, options = {})
      super(xml_node, options)

      @keyword = find_child_nodes(Statement::KEYWORD)
        .first
        .text
        .strip
      @object_name = find_child_nodes(Statement::IDENTIFIER)
        .first
        .text
        .strip

      @memory_scope = options[:memory_scope]
      @variable = memory_scope[@object_name]

      if variable.type == Statement::ARRAY_CLASS
        self.offset = "> #{Statement::EXPRESSION_STATEMENT} > #{Statement::EVALUATION_STATEMENT}"
      end

      self.expression_node = "> #{Statement::EXPRESSION_STATEMENT} > #{Statement::EVALUATION_STATEMENT}"
    end

    def emit_vm_code
      <<~VM_CODE
        #{expression_node.emit_vm_code(memory_scope)}
      VM_CODE
    end

    private

    def expression_node=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @expression_node = xml_nodes[-1..]
        .map(&:parent)
        .map { |node| Utils::XML.convert_to_jack_node(node, variable:, memory_scope:) }
        .first
    end

    def offset=(css_selector)
      @offset ||= find_child_nodes_with_css_selector(css_selector)
        .first
        .text
    end

    attr_reader :memory_scope, :offset
  end
end
