# frozen_string_literal: true

module JackCompiler
  class IfStatement < Statement
    REGEX = RegularExpressions::IF
    # EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_node)
      result = statements.match(IF_REGEX)
      if_statement_node = document.create_element('ifStatement')
      parent_node << if_statement_node

      keyword_node = document.create_element('keyword', 'if')
      if_statement << keyword_node

      symbol_node = document.create_element('symbol', '(')
      if_statement << symbol_node

      expression_node = document.create_element('expression')
      parent_node << expression_node

      symbol_node = document.create_element('symbol', ')')
      if_statement << symbol_node
    end
  end
end
