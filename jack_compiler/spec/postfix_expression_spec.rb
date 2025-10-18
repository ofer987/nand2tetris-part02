# frozen_string_literal: true

require_relative '../lib/jack_compiler'

RSpec.describe JackCompiler::PostfixExpression do
  describe '#initialize' do
    context 'infix_expression' do
      it 'returns an object' do
        expect(JackCompiler::PostfixExpression.new(infix_expression: '3 + 4')).to be_instance_of(JackCompiler::PostfixExpression)
      end
    end

    context 'expression' do
      it 'returns an object' do
        expect(JackCompiler::PostfixExpression.new(expression: '3 4 +')).to be_instance_of(JackCompiler::PostfixExpression)
      end
    end
  end
end
