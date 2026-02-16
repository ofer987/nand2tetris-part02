# frozen_string_literal: true

module JackCompiler
  class DoStatementNode < StatementNode
    NODE_NAME = Statement::DO_STATEMENT

    attr_reader :action, :object_name, :method_name, :memory_scope, :variable

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

      @memory_scope = options[:memory_scope]
      begin
        @variable = memory_scope[@object_name]
      rescue ArgumentError
        @variable = @object_name

        self.should_emit_function_vm_code = true
      end

      @symbol = find_child_nodes_with_css_selector("> #{Statement::SYMBOL}")
        .map(&:text)
        .map(&:strip)
        .first
    end

    def emit_vm_code
      return emit_function_vm_code if should_emit_function_vm_code

      result = []
      expression_list_node.parameters.each do |parameter|
        parameter_memory = memory_scope[parameter]

        result << <<~VM_CODE
          push #{parameter_memory.memory_location} #{parameter_memory.index}
        VM_CODE
      end

      result << <<~VM_CODE
        call #{variable.type}.#{method_name} #{expression_list_node.size + 1}

        pop temp 0
      VM_CODE

      result.join("\n")
    end

    private

    def emit_function_vm_code
      result = []
      expression_list_node.parameters.each do |parameter|
        parameter_memory = memory_scope[parameter]

        result << <<~VM_CODE
          push #{parameter_memory.memory_location} #{parameter_memory.index}
        VM_CODE
      end

      result << <<~VM_CODE
        call #{object_name}.#{method_name} #{expression_list_node.size}

        pop temp 0
      VM_CODE

      result.join("\n")
    end

    def push_into_argument_memory(expression_list_node_size)
      expression_list_node_size.times
        .map { |index| "push this #{index + 1}" }
        .join("\n")
    end

    def pop_into_argument_memory(expression_list_node_size)
      (expression_list_node_size + 1).times
        .map { |index| "pop argument #{expression_list_node_size - index}" }
        .join("\n")
    end

    def expression_list_node=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @expression_list_node = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node) }
        .first
    end

    attr_reader :expression_list_node
    attr_accessor :should_emit_function_vm_code
  end
end
