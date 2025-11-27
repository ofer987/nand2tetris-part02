# frozen_string_literal: true

require 'spec_helper'
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
      expect(subject.new(infix_expression: '3 + 4 / 5 * (6 + 7) ~ 8').calculate).to eq(-5)

      expect(subject.new(infix_expression: '6 & 7').calculate).to eq(6)
      expect(subject.new(infix_expression: '6 | 7').calculate).to eq(7)
    end

    it 'calculates expressions', :aggregate_failres do
      expect(subject.new(expression: '3 4 5 / 6 7 + * + 8 ~').calculate).to eq(-5)
      expect(subject.new(expression: '8 16 |').calculate).to eq(24)
      expect(subject.new(expression: 'false true |').calculate).to eq(1)
      expect(subject.new(expression: 'true true &').calculate).to eq(1)
      expect(subject.new(expression: 'true true +').calculate).to eq(2)
      expect(subject.new(expression: 'true false +').calculate).to eq(1)
      expect(subject.new(expression: 'false false +').calculate).to eq(0)
      expect(subject.new(expression: 'false true ~').calculate).to eq(-1)
      expect(subject.new(expression: 'false true &').calculate).to eq(0)
      expect(subject.new(expression: 'false true &').calculate).not_to eq(1)
    end

    it 'fails with unknown operator', :aggregate_failres do
      expect { subject.new(expression: '8 16 #').calculate }.to raise_error 'Postfix expression 8 16 # is invalid: result has 2 values instead of one (1)'
    end

    context 'with variables' do
      let(:index) { JackCompiler::PrimitiveMemory.new(name: 'index', type: 'int', index: 0, kind: JackCompiler::Memory::Kind::LOCAL) }
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
