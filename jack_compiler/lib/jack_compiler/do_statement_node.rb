# frozen_string_literal: true

module JackCompiler
  class DoStatementNode < StatementNode
    NODE_NAME = Statement::DO_STATEMENT

    attr_reader :action, :object_name, :method_name, :local_memory_index, :expression_node, :function_memory_index, :object_class

    def initialize(xml_node, options = {})
      super(xml_node, options)

      @action = find_child_nodes(Statement::KEYWORD)
        .map(&:text)
        .first

      @object_name, @method_name = find_child_nodes_with_css_selector("> #{Statement::IDENTIFIER}")[0..1]
        .map(&:text)

      self.expression_list_node = "> #{Statement::EXPRESSION_LIST}"

      local_memory = options[:local_memory]
      @local_memory_index = local_memory[@object_name]

      function_memory = options[:function_memory]
      @function_memory_index = function_memory[@object_name]

      object_classes = options[:object_classes]
      @object_class = object_classes[@object_name]

      @symbol = find_child_nodes_with_css_selector("> #{Statement::SYMBOL}")
        .map(&:text)
        .first
    end

    def emit_vm_code
      <<~VM_CODE
        push local #{local_memory_index}
        call #{object_class}.#{method_name} #{function_memory_index}
        #{expression_node.emit_vm_code}
        pop temp #{local_memory_index}
      VM_CODE
    end

    private

    def expression_list_node=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @expression_list_node = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node) }
        .first
    end
  end
end
