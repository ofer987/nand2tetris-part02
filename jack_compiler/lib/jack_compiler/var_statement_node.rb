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
      # binding.pry
      if find_child_nodes(Statement::KEYWORD).size > 1
        initialize_primitive_variable
      else
        initialize_class_variable
      end
    end

    def emit_vm_code
      ''
    end

    private

    def initialize_primitive_variable
      @memory_type = 'primitive'

      @object_class = find_child_nodes(Statement::KEYWORD)[1].text
      @object_names = find_child_nodes(Statement::IDENTIFIER)
        .map(&:text)
    end

    def initialize_class_variable
      @memory_type = 'class'

      @object_class = find_child_nodes(Statement::IDENTIFIER)[0].text
      @object_names = find_child_nodes(Statement::IDENTIFIER)[1..]
        .map(&:text)
    end

    # private
    #
    # def memory
    #   return @memory if defined? @memory
    #
    #   return unless local_memory.include? @object_name
    #
    #   @memory = local_memory[@object_name]
    # end
    #
    # def memory_type
    #   @memory_type ||= memory.type
    # end
    #
    # attr_reader :memory
  end
end
