# frozen_string_literal: true

module JackCompiler
  class ClassVariableNode < MemoryNode
    # TODO: implement MemoryNode properies
    NODE_NAME = Statement::CLASS_VAR_DESCRIPTION

    attr_reader :modifier, :class_name, :object_name, :memory_index

    def initialize(xml_node, options = {})
      super(xml_node, options)

      @memory_index = options[:memory_index]
      @modifier, @class_name = find_child_nodes(Statement::KEYWORD)
        .map(&:text)
      @object_name = find_child_nodes(Statement::IDENTIFIER)
        .first
        .text
    end

    def emit_vm_code
      # Empty
    end
  end
end
