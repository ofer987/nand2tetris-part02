# frozen_string_literal: true

module JackCompiler
  class FunctionNode < Node
    NODE_NAME = Statement::SUBROUTINE_DESCRIPTION

    attr_reader :class_name, :function_type, :function_name, :return_type, :local_memory_nodes, :statement_nodes

    def initialize(xml_node, options = {})
      super(xml_node, options)

      @class_name = options[:class_name]

      @function_type, @return_type = find_child_nodes(Statement::KEYWORD)[0..1]
        .map(&:text)

      @function_name = find_child_nodes(Statement::IDENTIFIER)
        .map(&:text)
        .first

      @symbols = find_child_nodes(Statement::SYMBOL)
        .map(&:text)

      @parameters_node = find_child_nodes(Statement::PARAMETER_LIST).first
      @subroutine_body_node = find_child_nodes(Statement::SUBROUTINE_BODY)
        .first

      @class_variable_nodes = options[:class_variable_nodes]
      self.local_memory_nodes = "> #{Statement::SUBROUTINE_BODY} > #{Statement::VAR_DESCRIPTION}"

      # rubocop:disable Layout/LineLength
      self.statement_nodes = "> #{Statement::SUBROUTINE_BODY} > #{Statement::STATEMENTS_STATEMENT} > #{Statement::LET_STATEMENT}, #{Statement::DO_STATEMENT}"

      self.return_node = "> #{Statement::SUBROUTINE_BODY} > #{Statement::STATEMENTS_STATEMENT} > #{Statement::RETURN_STATEMENT}"
      # rubocop:enable Layout/LineLength
    end

    def emit_vm_code
      <<~VM_CODE
        #{emit_statements_code}
      VM_CODE
    end

    private

    def local_memory_nodes=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @local_memory_nodes = []
      xml_nodes.each_with_index do |node, index|
        result = Utils::XML.convert_to_jack_node(node, memory_index: index)

        @local_memory_nodes << result
      end
    end

    def emit_statements_code
      @statement_nodes
        .map(&:emit_vm_code)
        .join("\n")
    end

    def statement_nodes=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      options = {
        local_memory: local_memory_nodes
          .map { |node| [node.object_name, node.memory_index] }
          .to_h,
        class_memory: class_variable_nodes
          .map { |node| [node.object_name, node.memory_index] }
          .to_h,
        object_classes: local_memory_nodes
          .map { |node| [node.object_name, node.object_class] }
          .to_h
      }

      @statement_nodes = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node, options) }
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

    attr_reader :class_variable_nodes
  end
end
