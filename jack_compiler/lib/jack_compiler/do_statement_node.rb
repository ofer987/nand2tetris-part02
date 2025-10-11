# frozen_string_literal: true

module JackCompiler
  class DoStatementNode < StatementNode
    NODE_NAME = Statement::DO_STATEMENT

    attr_reader :action, :object_name, :method_name, :local_memory, :class_memory_index, :object_class

    def initialize(xml_node, options = {})
      super(xml_node, options)

      @action = find_child_nodes(Statement::KEYWORD)
        .map(&:text)
        .map(&:strip)
        .first

      @object_name, @method_name = find_child_nodes_with_css_selector("> #{Statement::IDENTIFIER}")[0..1]
        .map(&:text)
        .map(&:strip)

      self.expression_list_node = "> #{Statement::EXPRESSION_LIST}"

      @local_memory = options[:local_memory][@object_name]
      @object_class = options[:object_classes][@object_name]

      class_memory = options[:class_memory]
      @class_memory_index = class_memory[@object_name]

      @symbol = find_child_nodes_with_css_selector("> #{Statement::SYMBOL}")
        .map(&:text)
        .map(&:strip)
        .first
    end

    def emit_vm_code
      <<~VM_CODE
        push local #{local_memory.index}
        call #{object_class}.#{method_name} #{expression_list_node.size + 1}
        pop temp #{local_memory.index}
      VM_CODE
    end

    private

    def expression_list_node=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @expression_list_node = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node) }
        .first
    end

    attr_reader :expression_list_node
  end
end
