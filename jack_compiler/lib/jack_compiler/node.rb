# frozen_string_literal: true

module JackCompiler
  class Node
    REGEX = //
    NODE_NAME = ''

    attr_reader :xml_node

    def initialize(xml_node)
      @xml_node = xml_node
    end

    def emit_vm_code
      raise NotImplementedError
    end

    protected

    def find_child_nodes(name)
      xml_node.children
        .select { |item| item.instance_of? Nokogiri::XML::Element }
        .select { |item| item.name == name }
    end

    def next_classes
      [VariableStatement, StatementsStatement]
    end

    def end_classes
      [CloseBraceStatement]
    end

    def else_classes
      [ElseStatement]
    end
  end
end
