# frozen_string_literal: true

module JackCompiler
  class VariableNode < Node
    # TODO: Use the same pattern as the VarStatementNode
    NODE_NAME = ''

    attr_reader :memory_index

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

    def kind
      Memory::Kind::LOCAL
    end

    def size
      @size ||= @names.size
    end

    def type
      return @type if defined? @type

      if primitive?
        @type = find_child_nodes(Statement::KEYWORD)[1].text.strip

        return
      end

      @type = find_child_nodes(Statement::IDENTIFIER)[0].text.strip
    end

    def names
      return @names if defined? @names

      if primitive?
        @names = find_child_nodes(Statement::IDENTIFIER)
          .map(&:text)
          .map(&:strip)

        return
      end

      @names ||= find_child_nodes(Statement::IDENTIFIER)[1..]
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

    protected

    attr_reader :keywords, :identifiers
  end
end
