# frozen_string_literal: true

module JackCompiler
  class TreeParser
    attr_reader :statement_classes

    def initialize
      @statement_classes = read_statement_classes_runtime
    end

    def statement_node(xml_node)
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
        .select { |item| statement_class? item }
    end

    def statement_class?(klazz)
      klazz.ancestors.include? JackCompiler::Statement
    end
  end
end
