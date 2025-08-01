# frozen_string_literal: true

module JackCompiler
  class ClassStatement < Statement
    REGEX = RegularExpressions::CLASS
    # EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(CLASS)
      # binding.pry

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, CLASS)
      result_node << keyword_node

      class_name_node = document.create_element(IDENTIFIER, result[1])
      result_node << class_name_node

      symbol_node = document.create_element(SYMBOL, OPEN_BRACE)
      result_node << symbol_node

      next_lines = lines.sub(REGEX, '')
      next_statements(result_node, next_lines)

      next_lines
    end

    protected

    def next_classes
      [ClassVariableStatement, ClassSubroutineStatement]
      # [FieldStatement, ConstructorStatement, FunctionStatement, MethodStatement]
    end

    private

    def inner_create_elements(parent_node, regex_result)
      term_node = document.create_element('term')
      parent_node << term_node

      identifier_node = document.create_element('identifier', regex_result[1])
      term_node << identifier_node

      symbol_node = document.create_element('symbol', regex_result[2])
      parent_node << symbol_node

      term_node = document.create_element('term')
      parent_node << term_node

      integer_constant = document.create_element('integerConstant', regex_result[3])
      term_node << integer_constant
    end
  end
end
