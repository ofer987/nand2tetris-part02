# frozen_string_literal: true

module JackCompiler
  class Node
    NODE_NAME = ''
    attr_reader :xml_node

    def initialize(xml_node, options = {})
      @xml_node = xml_node
      @options = options
    end

    def emit_vm_code
      raise NotImplementedError
    end

    protected

    def find_child_nodes_with_css_selector(selector)
      Utils::XML.find_child_nodes_with_css_selector(xml_node, selector)
    end

    def find_child_nodes(name)
      Utils::XML.find_child_nodes(xml_node, name)
    end

    attr_reader :options
  end
end
