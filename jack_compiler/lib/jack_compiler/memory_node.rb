# frozen_string_literal: true

module JackCompiler
  class MemoryNode < Node
    NODE_NAME = ''

    module FunctionType
      FUNCTION = 'function'
      METHOD = 'method'
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
        var_node = Utils::XML.convert_to_jack_node(node)

        var_node.object_names.each do |memory_name|
          case var_node.memory_type
          when Memory::ARRAY
            memory_item = ArrayMemory.new(
              name: memory_name,
              kind: var_node.object_kind,
              type: var_node.object_type
            )
          when Memory::CLASS
            memory_item = ClassMemory.new(
              name: memory_name,
              kind: var_node.object_kind,
              type: var_node.object_type
            )
          when Memory::PRIMITIVE
            memory_item = PrimitiveMemory.new(
              name: memory_name,
              kind: var_node.object_kind,
              type: var_node.object_type
            )
          else
            raise "Invalid memory type '#{var_node.memory_type}'"
          end

          memory_nodes << memory_item
        end
      end
      # rubocop:enable Metrics/BlockLength

      memory_nodes
    end
    # rubocop:enable Metrics/MethodLength
  end
end
