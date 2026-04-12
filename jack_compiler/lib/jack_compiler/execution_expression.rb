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

    # Copy this to somewhere in the PostfixCalculator#emit_vm_code
    def emit_vm_code(memory_scope)
      return '' if expression_list_node.blank?

      begin
        obj = memory_scope[object]
      rescue ArgumentError
        return emit_function_vm_code
      end

      result = []
      if obj.instance_of? ClassMemory
        result << <<~VM_CODE
          push #{obj.memory_location} #{obj.index}
        VM_CODE
      end

      expression_list_node.parameters.each do |parameter|
        parameter_memory = memory_scope[parameter]

        result << <<~VM_CODE
          push #{parameter_memory.memory_location} #{parameter_memory.index}
        VM_CODE
      end

      result << <<~VM_CODE
        call #{obj.type}.#{method_name} #{expression_list_node.size + 1}
      VM_CODE

      result.join("\n")
    end

    def calculate(objects); end

    private

    def emit_function_vm_code
      <<~VM_CODE
        call #{object}.#{method_name} #{expression_list_node.size}
        pop temp 0
      VM_CODE
    end

    def emit_vm_code_for_array_constructor
      array_size = expression_list_node.parameters.first.to_i

      <<~VM_CODE
        push constant #{array_size}
        call Array.new 1
      VM_CODE
    end

    def emit_vm_code_for_constructor
      <<~VM_CODE
        call #{object}.new #{expression_list_node.size}
      VM_CODE
    end

    def method_name
      xml_nodes = Array(Utils::XML.find_child_nodes_with_css_selector(
        xml_node,
        "> #{Statement::TERM_STATEMENT} > #{Statement::IDENTIFIER}"
      ))

      xml_nodes[1].text
    end

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
