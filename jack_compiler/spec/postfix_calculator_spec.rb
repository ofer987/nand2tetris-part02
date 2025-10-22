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

  describe '#calculate' do
    context 'when infix_expression is 6 + 7' do
      it 'is 13' do
        expect(subject.new(infix_expression: '6 + 7').calculate).to eq(13)
      end
    end

    context 'when infix_expression is 3 + 4' do
      it 'is 7' do
        expect(subject.new(infix_expression: '3 + 4').calculate).to eq(7)
      end
    end

    context 'when infix_expression is 3 + 4 / 5 * (6 + 7) - 8' do
      it 'is -5' do
        expect(subject.new(infix_expression: '3 + 4 / 5 * (6 + 7) - 8').calculate).to eq(-5)
      end
    end

    context 'when expression is 3 4 5 / 6 7 + * + 8 -' do
      it 'is -5' do
        expect(subject.new(expression: '3 4 5 / 6 7 + * + 8 -').calculate).to eq(-5)
      end
    end

    context 'when infix_expression is 1 + index ' do
      it 'raises an exception' do
        expect { subject.new(infix_expression: '1 + index').calculate }.to raise_error 'Variables are not implemented yet'
      end
    end
  end
end
