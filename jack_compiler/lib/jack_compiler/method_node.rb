# frozen_string_literal: true

module JackCompiler
  class MethodNode < MemoryNode
    NODE_NAME = Statement::SUBROUTINE_DESCRIPTION

    attr_reader :class_name, :function_type, :function_name, :return_type, :statement_nodes

    def variable_size
      @variable_size ||= memory_scope.local_size
    end

    # rubocop:disable Metrics/PerceivedComplexity
    def initialize(xml_node, options = {})
      super(xml_node, options)

      @class_name = options[:class_name]

      @function_type, @return_type = find_child_nodes(Statement::KEYWORD)[0..1]
        .map(&:text)
        .map(&:strip)

      @function_name = find_child_nodes(Statement::IDENTIFIER)
        .map(&:text)
        .map(&:strip)
        .first

      @symbols = find_child_nodes(Statement::SYMBOL)
        .map(&:text)
        .map(&:strip)

      argument_memory_scope = init_new_memory_scope(outer_memory_scope)
      nodes = memory_nodes("> #{Statement::PARAMETER_LIST} > #{Statement::TERM_STATEMENT}")
      nodes.each do |node|
        argument_memory_scope << node
      end
      # @argument_memory_scope.next_scope = outer_memory_scope

      @memory_scope = init_new_memory_scope(argument_memory_scope)
      nodes = memory_nodes("> #{Statement::SUBROUTINE_BODY} > #{Statement::VAR_DESCRIPTION}")
      nodes.each do |node|
        @memory_scope << node
      end

      @subroutine_body_node = find_child_nodes(Statement::SUBROUTINE_BODY)
        .first

      # rubocop:disable Layout/LineLength
      self.statement_nodes = "> #{Statement::SUBROUTINE_BODY} > #{Statement::STATEMENTS_STATEMENT} > #{Statement::LET_STATEMENT}, #{Statement::DO_STATEMENT}, #{Statement::IF_STATEMENT}, #{Statement::RETURN_STATEMENT}"
      # rubocop:enable Layout/LineLength
    end
    # rubocop:enable Metrics/PerceivedComplexity

    def emit_vm_code
      <<~VM_CODE
        #{emit_statements_code}
      VM_CODE
    end

    private

    def emit_statements_code
      @statement_nodes
        .map(&:emit_vm_code)
        .join("\n")
    end

    def statement_nodes=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @statement_nodes = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node, memory_scope:) }
    end

    def return_node=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @return_node = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node) }
        .first
    end

    def return_statement
      @return_statement ||= ReturnStatement.new(@return_node)
    end

    attr_reader :class_variable_nodes, :return_node
  end
end
