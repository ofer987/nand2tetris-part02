# frozen_string_literal: true

module JackCompiler
  class LetStatementNode < StatementNode
    REGEX = ''
    NODE_NAME = Statement::LET_STATEMENT

    attr_reader :class_name, :object_name, :expression_node

    def initialize(xml_node, options)
      super(xml_node, options)

      @keyword = find_child_nodes(Statement::KEYWORD)
        .first
        .text
        .strip
      @object_name = find_child_nodes(Statement::IDENTIFIER)
        .first
        .text
        .strip
      @memory = options[:local_memory][@object_name]

      self.expression_node = "> #{Statement::EXPRESSION_STATEMENT}"
    end

    def emit_vm_code
      <<~VM_CODE
        #{expression_node.emit_vm_code}
        pop local #{memory.index}
      VM_CODE
    end

    private

    def expression_node=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @expression_node = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node, memory:) }
        .first
    end

    attr_reader :memory
  end
end
