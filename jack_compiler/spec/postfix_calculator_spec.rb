# frozen_string_literal: true

require_relative '../lib/jack_compiler'

RSpec.describe JackCompiler::PostfixCalculator do
  subject { described_class }

  describe '#initialize', :agg do
    it 'returns an object', :aggregate_failres do
      expect(subject.new(expression: '3 + 4')).to be_instance_of(subject)
      expect(subject.new(expression: '3 4 +')).to be_instance_of(subject)
    end
  end

  describe '#calculate' do
    it 'calculates infix_expressions', :aggregate_failres do
      expect(subject.new(infix_expression: '6 + 7').calculate).to eq(13)
      expect(subject.new(infix_expression: '3 + 4').calculate).to eq(7)
      expect(subject.new(infix_expression: '3 + 4 / 5 * (6 + 7) - 8').calculate).to eq(-5)
    end

    it 'calculates expressions', :aggregate_failres do
      expect(subject.new(expression: '3 4 5 / 6 7 + * + 8 -').calculate).to eq(-5)
    end

    context 'with variables' do
      let(:index) { JackCompiler::PrimitiveMemory.new(name: 'index', memory_class: 'integer', index: 0, location: 0) }
      let(:memory) { { 'index' => index } }

      before(:each) do
        index.value = 5
      end

      it 'does not raise an error if expression contains variable', :aggregate_failres do
        expect { subject.new(infix_expression: '1 + index').calculate(memory:) }.not_to raise_error
        expect { subject.new(expression: '1 index +').calculate(memory:) }.not_to raise_error
      end

      it 'raises an error if memory does not have the variable', :aggregate_failres do
        expect { subject.new(infix_expression: '1 + j').calculate(memory:) }.to raise_error 'Variable \'j\' has not been declared'
        expect { subject.new(expression: '1 j +').calculate(memory:) }.to raise_error 'Variable \'j\' has not been declared'
      end
    end
  end
end
