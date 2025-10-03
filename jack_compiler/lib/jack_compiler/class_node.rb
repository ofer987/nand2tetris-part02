# frozen_string_literal: true

module JackCompiler
  class ClassNode < Node
    # REGEX = RegularExpressions::CLASS
    NODE_NAME = Statement::CLASS

    attr_reader :file_name, :class_node, :class_name, :class_variable_nodes, :function_nodes

    def initialize(xml_node, options = {})
      super(xml_node, options)

      @class_node = find_child_nodes_with_css_selector("> #{Statement::KEYWORD}")
        .map(&:text)
        .first

      @class_name = find_child_nodes_with_css_selector("> #{Statement::IDENTIFIER}")
        .map(&:text)
        .first

      self.class_variable_nodes = "> #{Statement::CLASS_VAR_DESCRIPTION}"
      self.function_nodes = "> #{Statement::SUBROUTINE_DESCRIPTION}"
    end

    def emit_vm_code
      function_nodes.map do |function_node|
        <<~VM_CODE
          function #{class_name}.#{function_node.function_name} #{class_variable_nodes.size}

          #{function_node.emit_vm_code}
        VM_CODE
      end.join("\n")
      #     # TODO: Do I need this?
      #     #{class_variable_nodes.map(&:emit_vm_code).join("\n")}
      #   VM_CODE
      # end
    end

    private

    def class_variable_nodes=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @class_variable_nodes = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node) }
    end

    def function_nodes=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @function_nodes = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node, class_name: class_name) }
    end
  end
end
