# frozen_string_literal: true

module JackCompiler
  class FunctionNode < Node
    NODE_NAME = Statement::SUBROUTINE_DESCRIPTION

    attr_reader :class_name, :function_type, :function_name, :return_type, :local_memory_nodes, :statement_nodes

    def variable_size
      @variable_size ||= local_memory_nodes.size
    end

    def initialize(xml_node, options = {})
      super(xml_node, options)

      @class_name = options[:class_name]

      @function_type, @return_type = find_child_nodes(Statement::KEYWORD)[0..1]
        .map(&:text)
        .map(&:strip)

      @function_name = find_child_nodes(Statement::IDENTIFIER)
        .map(&:text)
        .map(&:strip)
        .first

      @symbols = find_child_nodes(Statement::SYMBOL)
        .map(&:text)
        .map(&:strip)

      @parameters_node = find_child_nodes(Statement::PARAMETER_LIST).first
      @subroutine_body_node = find_child_nodes(Statement::SUBROUTINE_BODY)
        .first

      @class_variable_nodes = options[:class_variable_nodes]
      self.local_memory_nodes = "> #{Statement::SUBROUTINE_BODY} > #{Statement::VAR_DESCRIPTION}"

      # rubocop:disable Layout/LineLength
      self.statement_nodes = "> #{Statement::SUBROUTINE_BODY} > #{Statement::STATEMENTS_STATEMENT} > #{Statement::LET_STATEMENT}, #{Statement::DO_STATEMENT}, #{Statement::IF_STATEMENT}, #{Statement::RETURN_STATEMENT}"
      # rubocop:enable Layout/LineLength
    end

    def emit_vm_code
      <<~VM_CODE
        #{emit_statements_code}
      VM_CODE
    end

    private

    def local_memory_nodes=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @local_memory_nodes = []
      index = 0
      xml_nodes.each do |node|
        var_node = Utils::XML.convert_to_jack_node(node)

        var_node.object_names.each do |memory_name|
          case var_node.memory_type
          when Memory::ARRAY
            memory_item = ArrayMemory.new(
              name: memory_name,
              memory_class: var_node.object_class,
              location: var_node.memory_location,
              index: index
            )
          when Memory::CLASS
            memory_item = ClassMemory.new(
              name: memory_name,
              memory_class: var_node.object_class,
              location: var_node.memory_location,
              index: index
            )
          when Memory::PRIMITIVE
            memory_item = PrimitiveMemory.new(
              name: memory_name,
              memory_class: var_node.object_class,
              location: var_node.memory_location,
              index: index
            )
          else
            raise "Invalid memory type '#{var_node.memory_type}'"
          end

          @local_memory_nodes << memory_item

          index += 1
        end
      end
    end

    def emit_statements_code
      @statement_nodes
        .map(&:emit_vm_code)
        .join("\n")
    end

    def statement_nodes=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      # TODO: combine memory together
      options = {
        local_memory: local_memory_nodes
          .map { |node| [node.name, node] }
          .to_h,
        class_memory: class_variable_nodes
          .map { |node| [node.object_name, node] }
          .to_h,
        object_classes: local_memory_nodes
          .map { |node| [node.name, node.memory_class] }
          .to_h
      }

      @statement_nodes = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node, options) }
    end

    def return_node=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @return_node = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node) }
        .first
    end

    def return_statement
      @return_statement ||= ReturnStatement.new(@return_node)
    end

    attr_reader :class_variable_nodes, :return_node
  end
end
