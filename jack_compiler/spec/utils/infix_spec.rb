# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/jack_compiler'

RSpec.shared_examples '.to_postfix' do |infix_expression, postfix_expression|
  it "convert '#{infix_expression}' to '#{postfix_expression}'" do
    actual = subject.to_postfix(infix_expression)

    expect(actual).to eq(postfix_expression)
  end
end

RSpec.shared_examples '.to_postfix fails' do |infix_expression, postfix_expression|
  it "convert '#{infix_expression}' to '#{postfix_expression}'" do
    actual = subject.to_postfix(infix_expression)

    expect(actual).not_to eq(postfix_expression)
  end
end

RSpec.describe JackCompiler::Utils::Infix do
  subject { described_class }

  include_examples '.to_postfix', 'i | j', 'i j |'
  include_examples '.to_postfix', 'i * (~j)', 'i 0 j ~ *'
  include_examples '.to_postfix', '(3 + 4) * ~ 1', '3 4 + 0 1 ~ *'
  include_examples '.to_postfix', '~ 1 + (3) * 4', '0 1 ~ 3 4 * +'
  include_examples '.to_postfix', '~ 1 + (i) * 4', '0 1 ~ i 4 * +'
  include_examples '.to_postfix', '~ index + (i) * j', '0 index ~ i j * +'
  include_examples '.to_postfix', '~ 1 + (3 + 4)', '0 1 ~ 3 4 + +'
  include_examples '.to_postfix', '1 ~ ( ~ 1) + 3 + 4', '1 0 1 ~ ~ 3 + 4 +'
  include_examples '.to_postfix', '(3 + 4) ~ 1', '3 4 + 1 ~'
  include_examples '.to_postfix', '~ (3 + 4)', '0 3 4 + ~'
  include_examples '.to_postfix', '(3 + 4)', '3 4 +'
  include_examples '.to_postfix', '3 + 4', '3 4 +'
  include_examples '.to_postfix', '3+ 4', '3 4 +'
  include_examples '.to_postfix', '3+4', '3 4 +'
  include_examples '.to_postfix', '(3+4)', '3 4 +'
  include_examples '.to_postfix', '3+4 ~ 1', '3 4 + 1 ~'
  include_examples '.to_postfix', '3 + 4 / 5 * (6 + 7) ~ 8', '3 4 5 / 6 7 + * + 8 ~'
  # infix equals 7
  # The postfix 3 4 5 / 6 7 8 + ~ + *
  # equals
  include_examples '.to_postfix', '3 + 4 / 5 * (6 + 7 ~ 8)', '3 4 5 / 6 7 + 8 ~ * +'
  # infix equals 52.6
  include_examples '.to_postfix', '3 + 4 / 5 * (6 + 7 * 8)', '3 4 5 / 6 7 8 * + * +'
  include_examples '.to_postfix', '3 + 4 / 5 * (6 * 7 + 8)', '3 4 5 / 6 7 * 8 + * +'
  include_examples '.to_postfix', '3 + 4 / 5 * (6 * 7 + 8)', '3 4 5 / 6 7 * 8 + * +'
  include_examples '.to_postfix', '~1', '0 1 ~'
  include_examples '.to_postfix', '3 + 4 / 5 * (6 * 7 + 8) * 9 + 10', '3 4 5 / 6 7 * 8 + * 9 * + 10 +'
  include_examples '.to_postfix', '3 ~ 4 / 5 * (6 * 7 + 8) * 9 + 10', '3 4 5 / 6 7 * 8 + * 9 * ~ 10 +'
  include_examples '.to_postfix', '3 + 4 / 5 * (6 * 7 + 8) * 9 ~ 10', '3 4 5 / 6 7 * 8 + * 9 * + 10 ~'
  include_examples '.to_postfix fails', '3 + 4 ~ 1', '3 4 + 1 ~ /'

  describe 'to_postfix' do
    it 'raises error', :aggregate_failres do
      expect { subject.to_postfix '3 + 4 / 5 * (6 * 7 + 8) 8' }.to raise_error StandardError
      expect { subject.to_postfix '3 + 4 / 5 * (6 * 7 + 8 +' }.to raise_error StandardError
      expect { subject.to_postfix '3 + 4 / 5 * (6 * 7 + 8) +' }.to raise_error StandardError
      expect { subject.to_postfix '3 + 4 / 5 * (6 * 7 + 8 +) +' }.to raise_error StandardError
      expect { subject.to_postfix '6 - 8' }.to raise_error "Failed to traverse '6 - 8'"
    end
  end
end
