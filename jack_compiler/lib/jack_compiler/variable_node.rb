# frozen_string_literal: true

module JackCompiler
  class VariableNode < Node
    # TODO: Use the same pattern as the VarStatementNode
    NODE_NAME = ''

    attr_reader :memory_index, :keywords, :identifiers

    def array?
      return @array if defined? @array

      @array = identifiers.first.text.strip == Statement::ARRAY_CLASS
    end

    def primitive?
      @keywords.size >= 2
    end

    def reference?
      @keywords.size == 1
    end

    def class_name
      return identifiers.first.text if reference?

      raise 'This is not a class object'
    end

    def kind
      Memory::Kind::LOCAL
    end

    def size
      @size ||= @names.size
    end

    def type
      return @type if defined? @type

      if primitive?
        @type = @keywords[1].text.strip

        return @type
      end

      @type = @identifiers.first.text.strip
    end

    def names
      return @names if defined? @names

      if primitive?
        @names = @identifiers
          .map(&:text)
          .map(&:strip)

        return @names
      end

      @names ||= @identifiers[1..]
        .map(&:text)
        .map(&:strip)
    end

    def initialize(xml_node, options = {})
      super(xml_node, options)

      @memory_index = options[:memory_index]

      @keywords = find_child_nodes(Statement::KEYWORD)
      @identifiers = find_child_nodes(Statement::IDENTIFIER)
    end

    def emit_vm_code
      ''
    end
  end
end
