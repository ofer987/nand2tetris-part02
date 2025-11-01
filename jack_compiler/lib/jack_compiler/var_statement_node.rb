# frozen_string_literal: true

module JackCompiler
  class VarStatementNode < Node
    NODE_NAME = Statement::VAR_DESCRIPTION

    attr_reader :memory_index, :object_class, :object_names, :memory_type

    def size
      @size ||= @object_names.size
    end

    def memory_location
      'local'
    end

    def initialize(xml_node, options = {})
      super(xml_node, options)

      @memory_index = options[:memory_index]

      keywords = find_child_nodes(Statement::KEYWORD)
      identifiers = find_child_nodes(Statement::IDENTIFIER)
      if keywords.size > 1
        initialize_primitive_variable
      elsif identifiers.first.text == Statement::ARRAY_CLASS
        initialize_array_variable
      else
        initialize_class_variable
      end
    end

    def emit_vm_code
      ''
    end

    private

    def initialize_primitive_variable
      @memory_type = Memory::PRIMITIVE

      @object_class = find_child_nodes(Statement::KEYWORD)[1].text.strip
      @object_names = find_child_nodes(Statement::IDENTIFIER)
        .map(&:text)
        .map(&:strip)
    end

    def initialize_array_variable
      @memory_type = Memory::ARRAY

      @object_class = find_child_nodes(Statement::IDENTIFIER)[0].text.strip
      @object_names = find_child_nodes(Statement::IDENTIFIER)[1..]
        .map(&:text)
        .map(&:strip)
    end

    def initialize_class_variable
      @memory_type = Memory::CLASS

      @object_class = find_child_nodes(Statement::IDENTIFIER)[0].text.strip
      @object_names = find_child_nodes(Statement::IDENTIFIER)[1..]
        .map(&:text)
        .map(&:strip)
    end
  end
end
