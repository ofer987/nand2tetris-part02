# frozen_string_literal: true

module JackCompiler
  class LetStatementNode < StatementNode
    REGEX = ''
    NODE_NAME = ''

    attr_reader :class_name, :object_name, :local_memory_index, :expression_node

    def initialize(xml_node, local_memory)
      super(xml_node, local_memory)

      @class_name = find_child_nodes(Statement::KEYWORD)
      @object_name = find_child_nodes(Statement::IDENTIFIER)
      @local_memory_index = local_memory[@object_name]

      self.expression_node = "> #{Statement::EXPRESSION_STATEMENT}"
        .first
    end

    def emit_vm_code
      <<~VM_CODE
        #{expression_node.emit_vm_code}
        pop local #{local_memory_index}
      VM_CODE
    end

    private

    def expression_node=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @expression_list_node = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node) }
    end
  end
end
