# frozen_string_literal: true

module JackCompiler
  module Utils
    class XML
      class << self
        def convert_to_jack_node(xml_node, options = {})
          jack_node_classes
            .select { |jack_node_class| xml_node.name == jack_node_class::NODE_NAME }
            .map { |klazz| klazz.new(xml_node, options) }
            .first
        end

        def find_child_nodes_with_css_selector(xml_node, selector)
          xml_node.css(selector)
        end

        def find_child_nodes(xml_node, name)
          xml_node.children
            .select { |item| item.instance_of? Nokogiri::XML::Element }
            .select { |item| item.name == name }
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
  end
end
