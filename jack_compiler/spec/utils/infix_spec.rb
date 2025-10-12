# frozen_string_literal: true

require_relative '../../lib/jack_compiler'

RSpec.shared_examples '.to_postfix' do |infix_expression, postfix_expression|
  it 'Is of type JackCompiler::PostfixExpression' do
    actual = subject.to_postfix(infix_expression)

    expect(actual).to be_kind_of(JackCompiler::PostfixExpression)
  end

  it "convert '#{infix_expression}' to '#{postfix_expression}'" do
    actual = subject.to_postfix(infix_expression)

    expect(actual.expression).to eq(postfix_expression)
  end
end

RSpec.shared_examples '.to_postfix fails' do |infix_expression, postfix_expression|
  it "convert '#{infix_expression}' to '#{postfix_expression}'" do
    actual = subject.to_postfix(infix_expression)

    expect(actual.expression).not_to eq(postfix_expression)
  end
end

RSpec.describe JackCompiler::Utils::Infix do
  subject { described_class }

  include_examples '.to_postfix', '(3 + 4)', '3 4 +'
  include_examples '.to_postfix', '3 + 4', '3 4 +'
  include_examples '.to_postfix', '3+ 4', '3 4 +'
  include_examples '.to_postfix', '3+4', '3 4 +'
  include_examples '.to_postfix', '(3+4)', '3 4 +'
  include_examples '.to_postfix', '3+4 - 1', '3 4 + 1 -'
  include_examples '.to_postfix', '3 + 4 / 5 * (6 + 7) - 8', '3 4 5 / 6 7 + * + 8 -'
  include_examples '.to_postfix fails', '3 + 4 - 1', '3 4 + 1 - /'
end
