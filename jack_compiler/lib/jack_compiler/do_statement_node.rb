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
      @variable = memory_scope[@object_name]

      @symbol = find_child_nodes_with_css_selector("> #{Statement::SYMBOL}")
        .map(&:text)
        .map(&:strip)
        .first
    end

    def emit_vm_code
      <<~VM_CODE
        // Temporarily remember the current value of _this_
        push pointer 0
        pop temp 0

        // TODO: push rest of variables in the expression list
        // Push the object first, and the rest of the parameters into the stack
        push #{variable.kind} #{variable.index}
        #{expression_list_node.emit_vm_code(memory_scope)}

        // Now we pop the values off the stack into the argument memory in reverse order
        #{pop_into_argument_memory(expression_list_node.size)}
        call #{variable.type}.#{method_name} #{expression_list_node.size + 1}
        // TODO: Configure the "Call" to pop the first argument into pointer 0 and then into push into _this 0_

        // pop the empty return statement off the stack
        pop temp 0

        // Reconfigure the caller's _this_ and its arguments will be automatically reconfigured
        push temp 0
        pop pointer 0
        push this 0
      VM_CODE
    end

    private

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
  end
end
