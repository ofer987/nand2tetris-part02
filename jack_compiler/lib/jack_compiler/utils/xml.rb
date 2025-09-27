# frozen_string_literal: true

module Utils
  class XML < self
    def convert_to_jack_node(xml_node)
      result = jack_node_classes
        .select { |jack_node_class| xml_node.name == jack_node_class::NODE_NAME }
        .first

      raise "Failed to find Jack Node for #{xml_node.name}" if result.blank?

      result
    end

    private

    def jack_node_classes
      @jack_node_classes ||= JackCompiler.constants
        .map { |item| JackCompiler.const_get(item) }
        .select { |item| item.is_a? Class }
        .select { |item| node_class? item }
    end

    def node_class?(klazz)
      klazz.ancestors.include? JackCompiler::Node
    end
  end
end
