# frozen_string_literal: true

module JackCompiler
  class LetStatementNode < StatementNode
    REGEX = ''
    NODE_NAME = Statement::LET_STATEMENT

    attr_reader :class_name, :object_name, :expression_node

    def initialize(xml_node, options)
      super(xml_node, options)

      @keyword = find_child_nodes(Statement::KEYWORD)
        .first
        .text
        .strip
      @object_name = find_child_nodes(Statement::IDENTIFIER)
        .first
        .text
        .strip
      if @object_name.match? RegularExpressions::ARRAY_EXPRESSION
        matches = @object_name.match(RegularExpressions::ARRAY_EXPRESSION)
        @object_name = matches[2]
        @offset = matches[4]
      end

      self.objects = options
      @memory = options[:local_memory][@object_name]

      self.expression_node = "> #{Statement::EXPRESSION_STATEMENT} > #{Statement::EVALUATION_STATEMENT}"
    end

    def emit_vm_code
      <<~VM_CODE
        #{expression_node.emit_vm_code(objects)}
        #{memory.assignment_vm_code({ offset: offset })}
      VM_CODE
    end

    private

    def objects=(options)
      @objects = {}

      options[:class_memory].each do |name, memory|
        @objects[name] = memory
      end

      options[:local_memory].each do |name, memory|
        @objects[name] = memory
      end
    end

    def expression_node=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @expression_node = xml_nodes[0..0]
        .map(&:parent)
        .map { |node| Utils::XML.convert_to_jack_node(node, memory:, objects:) }
        .first
    end

    attr_reader :memory, :objects, :offset
  end
end
