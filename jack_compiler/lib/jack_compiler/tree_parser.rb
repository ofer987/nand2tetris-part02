# frozen_string_literal: true

module JackCompiler
  class TreeParser
    attr_reader :statement_classes

    def initialize
      @statement_classes = read_statement_classes_runtime
    end

    def put_vm_code(xml_node)
      result = []
      node_class = to_node_class(xml_node)

      unless node_class.nil?
        node = node_class.new(xml_node)

        result << node.emit_vm_code
      end

      xml_node.children.each do |item|
        result << put_vm_code(item)
      end

      result.flatten
    end

    def to_node_class(xml_node)
      node_name = xml_node.name

      statement_classes
        .select { |klazz| node_name == klazz::NODE_NAME }
        .first
    end

    private

    def read_statement_classes_runtime
      JackCompiler.constants
        .map { |item| JackCompiler.const_get(item) }
        .select { |item| item.is_a? Class }
        .select { |item| node_class? item }
    end

    def node_class?(klazz)
      klazz.ancestors.include? JackCompiler::Node
    end
  end
end
