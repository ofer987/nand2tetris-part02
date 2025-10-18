# frozen_string_literal: true

require_relative '../lib/jack_compiler'

RSpec.describe JackCompiler::PostfixCalculator do
  subject { described_class }

  context '#initialize' do
    context 'infix_expression' do
      it 'returns an object' do
        expect(subject.new(expression: '3 + 4')).to be_instance_of(subject)
      end
    end

    context 'expression' do
      it 'returns an object' do
        expect(subject.new(expression: '3 4 +')).to be_instance_of(subject)
      end
    end
  end
end
