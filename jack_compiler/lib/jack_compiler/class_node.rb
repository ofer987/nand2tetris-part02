# frozen_string_literal: true

module JackCompiler
  class ClassNode < Node
    # REGEX = RegularExpressions::CLASS
    NODE_NAME = Statement::CLASS

    attr_reader :file_name, :class_node, :class_name, :class_variable_nodes, :function_nodes

    def initialize(xml_node)
      super(xml_node)

      @class_node = find_child_nodes_with_css_selector("> #{Statement::KEYWORD}")
        .map(&:text)
        .first

      @class_name = find_child_nodes_with_css_selector("> #{Statement::IDENTIFIER}")
        .map(&:text)
        .first

      @class_variable_nodes = find_child_nodes_with_css_selector("> #{Statement::CLASS_VAR_DESCRIPTION}")

      @function_nodes = find_child_nodes_with_css_selector("> #{Statement::SUBROUTINE_DESCRIPTION}")
    end

    def emit_vm_code
      ''
    end
  end
end
