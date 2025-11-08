# frozen_string_literal: true

module JackCompiler
  class ClassNode < Node
    NODE_NAME = Statement::CLASS

    attr_reader :file_name, :class_node, :class_name, :class_variable_nodes, :function_nodes, :class_memory_scope

    def initialize(xml_node, options = {})
      super(xml_node, options)

      @class_node = find_child_nodes_with_css_selector("> #{Statement::KEYWORD}")
        .map(&:text)
        .map(&:strip)
        .first

      @class_name = find_child_nodes_with_css_selector("> #{Statement::IDENTIFIER}")
        .map(&:text)
        .map(&:strip)
        .first

      self.class_memory_scope = "> #{Statement::CLASS_VAR_DESCRIPTION}"
      self.function_nodes = "> #{Statement::SUBROUTINE_DESCRIPTION}"
    end

    def emit_vm_code
      function_nodes.map do |function_node|
        <<~VM_CODE
          function #{class_name}.#{function_node.function_name} #{function_node.variable_size}

          #{function_node.emit_vm_code}
        VM_CODE
      end.join("\n")
      #     # TODO: Do I need this?
      #     #{class_variable_nodes.map(&:emit_vm_code).join("\n")}
      #   VM_CODE
      # end
    end

    private

    #
    # def class_variable_nodes=(css_selector)
    #   xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))
    #
    #   @class_variable_nodes = []
    #   xml_nodes.each_with_index do |node, index|
    #     variable_node = Utils::XML.convert_to_jack_node(node, memory_index: index)
    #     @class_variable_nodes << variable_node
    #   end
    # end

    def class_memory_scope=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      class_memory_nodes = {}
      # TODO: index should be per kind
      index = 0
      xml_nodes.each do |node|
        var_node = Utils::XML.convert_to_jack_node(node)

        var_node.object_names.each do |memory_name|
          case var_node.memory_type
          when Memory::ARRAY
            memory_item = ArrayMemory.new(
              name: memory_name,
              kind: var_node.object_kind,
              type: var_node.object_type,
              index: index
            )
          when Memory::CLASS
            memory_item = ClassMemory.new(
              name: memory_name,
              kind: var_node.object_kind,
              type: var_node.object_type,
              index: index
            )
          when Memory::PRIMITIVE
            memory_item = PrimitiveMemory.new(
              name: memory_name,
              kind: var_node.object_kind,
              type: var_node.object_type,
              index: index
            )
          else
            raise "Invalid memory type '#{var_node.memory_type}'"
          end

          class_memory_nodes[memory_name] = memory_item

          index += 1
        end
      end

      @class_memory_scope = MemoryScope.new(class_memory_nodes)
    end

    def function_nodes=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      options = {
        class_name: class_name,
        memory_scope: class_memory_scope
      }
      @function_nodes = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node, options) }
    end
  end
end
