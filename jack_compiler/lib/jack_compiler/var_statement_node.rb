# frozen_string_literal: true

module JackCompiler
  class VarStatementNode < StatementNode
    REGEX = RegularExpressions::VAR_STATEMENT
    NODE_NAME = Statement::VAR_DESCRIPTION

    attr_reader :attr_names

    def initialize(xml_node, local_memory)
      super(xml_node, local_memory)

      @keyword = find_child_nodes(Statement::KEYWORD)
      @type, @name = find_child_nodes(Statement::IDENTIFIER)[0..1]
    end

    def emit_vm_code
      <<~VM_CODE
        call #{memory.object_name}.

        pop
      VM_CODE
    end

    private

    def memory
      return @memory if defined? @memory

      return unless local_memory.include? @object_name

      @memory = local_memory[@object_name]
    end

    def memory_type
      @memory_type ||= memory.type
    end

    attr_reader :memory
  end
end
