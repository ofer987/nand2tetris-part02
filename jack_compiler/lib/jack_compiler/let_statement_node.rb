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

      @object_name, @object_index = @object_name.match(/^(.+)\[(.+)\]$/)[1..2] if /\[.+/.match?(@object_name)

      @memory_scope = options[:memory_scope]
      @variable = memory_scope[@object_name]

      @offset = @object_index if variable.instance_of? ArrayMemory

      self.expression_node = "> #{Statement::EXPRESSION_STATEMENT} > #{Statement::EVALUATION_STATEMENT}"
    end

    def emit_vm_code
      <<~VM_CODE
        #{prepare_variable_store_result}
        #{expression_node.emit_vm_code(memory_scope)}
        #{temporarily_store_result}
        #{emit_assignment_vm_code}
      VM_CODE
    end

    private

    def prepare_variable_store_result
      variable.prepare_memory(memory_scope:, offset:)
    end

    def emit_assignment_vm_code
      <<~VM_CODE
        # Push temporary value into indexed array
        push #{Memory::TEMPORARY_MEMORY}
        #{variable.assignment_vm_code(offset:)}
      VM_CODE
    end

    def temporarily_store_result
      <<~VM_CODE
        pop #{Memory::TEMPORARY_MEMORY}
      VM_CODE
    end

    def expression_node=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @expression_node = xml_nodes[-1..]
        .map(&:parent)
        .map { |node| Utils::XML.convert_to_jack_node(node, variable:, memory_scope:, offset:) }
        .first
    end

    attr_reader :memory_scope, :offset
  end
end
