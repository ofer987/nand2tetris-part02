# frozen_string_literal: true

module JackCompiler
  # rubocop:disable Metrics/ClassLength
  class ClassNode < Node
    NODE_NAME = Statement::CLASS

    attr_reader :file_name, :class_node, :class_name, :function_nodes, :method_nodes, :constructor_nodes

    def static_memory_scope
      return @static_memory_scope if defined? @static_memory_scope

      @static_memory_scope = MemoryScope.new(static_memory)
    end

    def field_memory_scope
      return @field_memory_scope if defined? @field_memory_scope

      @field_memory_scope = MemoryScope.new(field_memory, static_memory_scope)
    end

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

      self.static_memory = "> #{Statement::CLASS_VAR_DESCRIPTION}"
      self.field_memory = "> #{Statement::CLASS_FIELD_VAR_DESCRIPTION}"
      self.function_nodes = "> #{Statement::SUBROUTINE_DESCRIPTION}"
      self.method_nodes = "> #{Statement::METHOD_DESCRIPTION}"
      self.constructor_nodes = "> #{Statement::CONSTRUCTOR_DESCRIPTION}"
    end

    def emit_vm_code
      function_nodes.map do |function_node|
        <<~VM_CODE
          function #{class_name}.#{function_node.function_name} #{function_node.variable_size}

          #{function_node.emit_vm_code}
        VM_CODE
      end.join("\n")

      constructor_nodes.map do |function_node|
        <<~VM_CODE
          function #{class_name}.#{function_node.function_name} #{function_node.variable_size}

          #{function_node.emit_vm_code}
        VM_CODE
      end.join("\n")

      method_nodes.map do |function_node|
        <<~VM_CODE
          function #{class_name}.#{function_node.function_name} #{function_node.variable_size}

          #{function_node.emit_vm_code}
        VM_CODE
      end.join("\n")
    end

    private

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def static_memory=(css_selector)
      static_xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))
        .map { |node| Utils::XML.convert_to_jack_node(node) }
        .select { |xml_node| xml_node.kind == Memory::Kind::STATIC }

      @static_memory = {}
      # rubocop:disable Metrics/BlockLength
      static_xml_nodes.each do |xml_node|
        index = Memory.next_static_memory_index

        xml_node.names.each do |name|
          if xml_node.primitive?
            static_name = "#{class_name}.#{name}"
            memory_item = PrimitiveMemory.new(
              type: xml_node.type,
              name: static_name,
              kind: xml_node.kind,
              index: index
            )
          elsif xml_node.array?
            memory_item = ArrayMemory.new(
              type: xml_node.type,
              name: static_name,
              kind: xml_node.kind,
              index: index
            )
          elsif xml_node.reference?
            memory_item = ClassMemory.new(
              type: xml_node.type,
              name: static_name,
              kind: xml_node.kind,
              index: index
            )
          else
            raise "Invalid memory type '#{xml_node.type}'"
          end

          @static_memory[static_name] = memory_item
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def field_memory=(css_selector)
      field_xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))
        .map { |node| Utils::XML.convert_to_jack_node(node) }
        .select { |xml_node| xml_node.kind == Memory::Kind::FIELD }

      @field_memory = {}
      index = 0
      # rubocop:disable Metrics/BlockLength
      field_xml_nodes.each do |xml_node|
        xml_node.names.each do |name|
          if xml_node.primitive?
            memory_item = PrimitiveMemory.new(
              type: xml_node.type,
              name: name,
              kind: xml_node.kind,
              index: index
            )
          elsif xml_node.array?
            memory_item = ArrayMemory.new(
              type: xml_node.type,
              name: name,
              kind: xml_node.kind,
              index: index
            )
          elsif xml_node.reference?
            memory_item = ClassMemory.new(
              type: xml_node.type,
              name: name,
              kind: xml_node.kind,
              index: index
            )
          else
            raise "Invalid memory type '#{xml_node.type}'"
          end

          @field_memory[name] = memory_item

          index += 1
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength

    def function_nodes=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      options = {
        class_name: class_name,
        memory_scope: static_memory_scope
      }
      @function_nodes = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node, options) }
        .select { |node| node.function_type == MemoryNode::FunctionType::FUNCTION }
    end

    def method_nodes=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      options = {
        class_name: class_name,
        memory_scope: field_memory_scope
      }
      @method_nodes = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node, options) }
        .select { |node| node.function_type == MemoryNode::FunctionType::METHOD }
    end

    def constructor_nodes=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      options = {
        class_name: class_name,
        memory_scope: field_memory_scope
      }
      @constructor_nodes = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node, options) }
        .select { |node| node.function_type == MemoryNode::FunctionType::CONSTRUCTOR }
    end

    attr_reader :static_memory, :field_memory
  end
  # rubocop:enable Metrics/ClassLength
end
