# frozen_string_literal: true

module JackCompiler
  class ExecutionExpression
    class << self
      def execution_node?(xml_node)
        evaluation_node = Utils::XML.find_child_nodes_with_css_selector(
          xml_node,
          "> #{Statement::EVALUATION_TYPE_STATEMENT}"
        ).first

        return false if evaluation_node.blank?

        evaluation_node.text == Statement::EXECUTION_TYPE
      end
    end

    attr_reader :object, :method, :symbol, :expression_list_node

    def initialize(xml_node, variable:, offset:)
      @xml_node = xml_node
      @variable = variable
      @offset = offset

      @object, @method = Utils::XML.find_child_nodes_with_css_selector(
        xml_node,
        "> #{Statement::TERM_STATEMENT} > #{Statement::IDENTIFIER}"
      )[0..1]
        .map(&:text)
        .map(&:strip)

      self.expression_list_node = "> #{Statement::TERM_STATEMENT} > #{Statement::EXPRESSION_LIST}"

      @symbol = Utils::XML.find_child_nodes_with_css_selector(xml_node, "> #{Statement::SYMBOL}")
        .map(&:text)
        .map(&:strip)
        .first

      variable.value = Memory::NULL_VALUE
    end

    def emit_vm_code(memory_scope)
      return '' if expression_list_node.blank?

      object_name = object
      begin
        object_in_memory = memory_scope[object]
        object_name = object_in_memory.type if object_in_memory.instance_of?(ClassMemory) && non_constructor_method?
      rescue ArgumentError
        object_name = object
      end

      <<~VM_CODE
        // Set up the "this" segment
        push pointer 0

        // Not required: Pop arguments
        // push Arguments
        #{expression_list_node.emit_vm_code(memory_scope)}

        call #{object_name}.#{method} #{expression_list_node.size + 1}

        // TODO: Method should pop the pointer into local variable
        // TODO: Both Functions/Methods should pop the stack into argument variables
        #{variable.assign_value_from_stack}

        // Reconfigure the caller's _this_ and its arguments will be automatically reconfigured
        push temp 0
        pop pointer 0
        push this 0
      VM_CODE
    end

    def calculate(objects); end

    private

    def non_constructor_method?
      xml_nodes = Array(Utils::XML.find_child_nodes_with_css_selector(
        xml_node,
        "> #{Statement::TERM_STATEMENT} > #{Statement::IDENTIFIER}"
      ))

      return false if xml_nodes.size < 2

      # The method name is the second identifier
      # Return true if this is a regular method
      # Return false if this is a constructor
      true if xml_nodes.map(&:text)[1] != Statement::CONSTRUCTOR_METHOD_CALL
    end

    def expression_list_node=(css_selector)
      xml_nodes = Array(Utils::XML.find_child_nodes_with_css_selector(xml_node, css_selector))

      @expression_list_node = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node) }
        .first
    end

    attr_reader :xml_node, :variable, :memory_scope, :offset
  end
end
