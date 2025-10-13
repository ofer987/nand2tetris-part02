# frozen_string_literal: true

require_relative '../lib/jack_compiler'

RSpec.describe JackCompiler::PostfixExpression do
  describe '#initialize' do
    it 'returns an object' do
      expect(JackCompiler::PostfixExpression.new([])).to be_instance_of(JackCompiler::PostfixExpression)
    end
  end
end
