# frozen_string_literal: true

module JackCompiler
  class MemoryNode < Node
    NODE_NAME = ''

    module FunctionType
      FUNCTION = 'function'
      METHOD = 'method'
      CONSTRUCTOR = 'constructor'
    end

    attr_reader :memory_scope, :outer_memory_scope

    def function_type
      raise NotImplementedError
    end

    def initialize(xml_node, options = {})
      super(xml_node, options)

      @outer_memory_scope = options[:memory_scope] || {}
    end

    protected

    def init_new_memory_scope(outer_memory_scope)
      MemoryScope.new({}, outer_memory_scope)
    end

    # rubocop:disable Metrics/MethodLength
    def memory_nodes(css_selector)
      memory_nodes = []

      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      # rubocop:disable Metrics/BlockLength
      xml_nodes.each do |node|
        xml_node = Utils::XML.convert_to_jack_node(node)

        index = 0
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

          memory_nodes << memory_item
          index += 1
        end
      end
      # rubocop:enable Metrics/BlockLength

      memory_nodes
    end
    # rubocop:enable Metrics/MethodLength
  end
end
