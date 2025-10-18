# frozen_string_literal: true

module JackCompiler
  class PostfixCalculator
    def initialize(infix_expression: '', expression: '')
      @infix_expression = infix_expression unless infix_expression.blank?
      @expression = expression unless expression.blank?

      raise 'Should provide either infix_expression or expression' if infix_expression.blank? && expression.blank?
    end

    def expression
      return @expression if defined? @expression

      @expression = Utils::Infix.to_postfix(infix_expression)
    end

    def calculate(_memories)
      0
    end

    private

    attr_reader :infix_expression
  end
end
