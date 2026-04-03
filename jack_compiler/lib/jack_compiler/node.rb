# frozen_string_literal: true

module JackCompiler
  class Node
    NODE_NAME = ''

    # rubocop:disable Layout/LineLength
    PARENT_NODE_CSS_SELECTOR = "> #{Statement::SUBROUTINE_BODY} > #{Statement::STATEMENTS_STATEMENT}".freeze
    STATEMENT_NODES_CSS_SELECTOR = "> #{Statement::LET_STATEMENT}, #{Statement::DO_STATEMENT}, #{Statement::IF_STATEMENT}, #{Statement::WHILE_STATEMENT}, #{Statement::RETURN_STATEMENT}".freeze
    IF_ELSE_STATEMENT_NODES_CSS_SELECTOR = "#{Statement::LET_STATEMENT}, #{Statement::DO_STATEMENT}, #{Statement::WHILE_STATEMENT}, #{Statement::IF_STATEMENT}".freeze
    # rubocop:enable Layout/LineLength

    attr_reader :xml_node

    def initialize(xml_node, options = {})
      @xml_node = xml_node
      @options = options
      @memory_scope = options[:memory_scope]
    end

    def emit_vm_code
      raise NotImplementedError
    end

    protected

    def find_child_nodes_with_css_selector(selector)
      Utils::XML.find_child_nodes_with_css_selector(xml_node, selector)
    end

    def find_child_nodes(name)
      Utils::XML.find_child_nodes(xml_node, name)
    end

    attr_reader :options, :memory_scope
  end
end
