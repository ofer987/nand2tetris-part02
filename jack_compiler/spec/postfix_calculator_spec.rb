# frozen_string_literal: true

require_relative '../lib/jack_compiler'

RSpec.describe JackCompiler::PostfixCalculator do
  describe '#initialize' do
    context 'infix_expression' do
      it 'returns an object' do
        expect(JackCompiler::PostfixCalculator.new(infix_expression: '3 + 4')).to be_instance_of(JackCompiler::PostfixCalculator)
      end
    end

    context 'expression' do
      it 'returns an object' do
        expect(JackCompiler::PostfixCalculator.new(expression: '3 4 +')).to be_instance_of(JackCompiler::PostfixCalculator)
      end
    end
  end
end
