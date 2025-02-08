# frozen_string_literal: true

module JackCompiler
  class IfStatement < Statement
    REGEX = RegularExpressions::IF
    EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_element)
      result = statements.match(IF_REGEX)
      if_statement_node = document.create_element('ifStatement')
      parent_element << if_statement_node

      keyword_node = document.create_element('keyword', 'if')
      if_statement << keyword_node

      symbol_node = document.create_element('symbol', '(')
      if_statement << symbol_node

      expression_node = document.create_element('expression')
      parent_element << expression_node

      inner_create_elements(expression_node, result)

      symbol_node = document.create_element('symbol', ')')
      if_statement << symbol_node
    end

    def next_statements
      raise NotImplementedError
    end

    private

    def inner_create_elements(parent_element, regex_result)
      term_node = document.create_element('term')
      parent_element << term_node

      identifier_node = document.create_element('identifier', regex_result[1])
      term_node << identifier_node

      symbol_node = document.create_element('symbol', regex_result[2])
      parent_element << symbol_node

      term_node = document.create_element('term')
      parent_element << term_node

      integer_constant = document.create_element('integerConstant', regex_result[3])
      term_node << integer_constant
    end
  end
end
