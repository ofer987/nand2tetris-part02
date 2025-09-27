# frozen_string_literal: true

module JackCompiler
  class FunctionNode < Node
    NODE_NAME = Statement::SUBROUTINE_DESCRIPTION

    attr_reader :class_name, :function_type, :function_name, :return_type

    def initialize(xml_node, options = {})
      super(xml_node, options)

      @class_name = options[:class_name]

      keywords = find_child_nodes(Statement::KEYWORD)
      @function_type = keywords[0]
      @return_type = keywords[1]
      @function_name = find_child_nodes(Statement::IDENTIFIER).first

      @symbols = find_child_nodes(Statement::SYMBOL)
      @parameters_node = find_child_nodes(Statement::PARAMETER_LIST).first

      @subroutine_body_node = find_child_nodes(Statement::SUBROUTINE_BODY)
        .first
      @local_memory_nodes = find_child_nodes_with_css_selector(
        "> #{Statement::SUBROUTINE_BODY} > #{Statement::VAR_DESCRIPTION}"
      )

      # rubocop:disable Layout/LineLength
      @statement_nodes = find_child_nodes_with_css_selector(
        "> #{Statement::SUBROUTINE_BODY} > #{STATEMENTS_STATEMENT} > #{Statement::LET_STATEMENT}, #{Statement::DO_STATEMENT}"
      )
      # rubocop:enable Layout/LineLength

      @return_node = find_child_nodes_with_css_selector(
        "> #{Statement::SUBROUTINE_BODY} > #{STATEMENTS_STATEMENT} > #{Statement::RETURN_STATEMENT}"
      )
    end

    def emit_vm_code
      <<~VM_CODE
        #{class_name}.#{function_name}.#{local_memory.size}

        #{emit_statements_code}
      VM_CODE
    end

    private

    def emit_statements_code
      @statement_nodes.map(&:emit_vm_code)
    end

    def local_memory
      return @local_memory if defined? @local_memory

      @local_memory = {}
      return if local_memory_nodes.blank?

      local_memory_nodes.each_with_index do |item, index|
        memory << LocalMemoryNode.new(item, index)
      end

      memory.each do |item|
        key = item.object_name

        @local_memory[key] = item
      end

      # TODO, convert to a Hash where the key is the variable name
      @local_memory
    end

    def statements
      @statements ||= @statement_nodes.map { |item| StatementNode.new(item, local_memory) }
    end

    def return_statement
      @return_statement ||= ReturnStatement.new(@return_node)
    end

    attr_reader :local_memory_nodes, :subroutine_body_node
  end
end
