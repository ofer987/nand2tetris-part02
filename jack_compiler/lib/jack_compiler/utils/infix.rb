# frozen_string_literal: true

module JackCompiler
  module Utils
    # rubocop:disable Metrics/ClassLength
    class Infix
      OPERATORS_LIST_REGEX = %r{[*/+-]}

      MONOMIAL_REGEX = /^\s*([+-])\s*(\w+)\s*/
      MONOMIAL_REGEX_OPEN_ROUND_BRACKET = /^\s*([+-])\s*(\()\s*/
      OPERATOR_REGEX = /^\s*(#{OPERATORS_LIST_REGEX})\s*/
      ARRAY_OPERAND_REGEX = /^\s*(\w+\[\d+\])\s*/
      OPERAND_REGEX = /^\s*(\w+)\s*/
      OPEN_ROUND_BRACKET_REGEX = /^\s*(\()\s*/
      CLOSE_ROUND_BRACKET_REGEX = /^\s*(\))\s*/

      INVALID_REGEX = /#{OPERATORS_LIST_REGEX}\s*$/

      OPEN_ROUND_BRACKET = '('
      CLOSE_ROUND_BRACKET = ')'

      PLUS = '+'
      MINUS = '-'
      MULTIPLY = '*'
      DIVIDE = '/'

      OPERATORS = [PLUS, MINUS, MULTIPLY, DIVIDE].freeze

      OPERATOR_PRIORITY = {
        PLUS => 0,
        MINUS => 0,
        MULTIPLY => 1,
        DIVIDE => 1
      }.freeze

      REGEXES = {
        start: {
          regex: nil,
          next_regex_keys: %i[open_round_bracket array_operand operand monomial monomial_open_round_bracket],
          stack_type: nil
        },
        operator: {
          regex: OPERATOR_REGEX,
          next_regex_keys: %i[array_operand operand open_round_bracket monomial],
          stack_type: :stack
        },
        array_operand: {
          regex: ARRAY_OPERAND_REGEX,
          next_regex_keys: %i[operator close_round_bracket],
          stack_type: :postfix_stack
        },
        operand: {
          regex: OPERAND_REGEX,
          next_regex_keys: %i[operator close_round_bracket],
          stack_type: :postfix_stack
        },
        open_round_bracket: {
          regex: OPEN_ROUND_BRACKET_REGEX,
          next_regex_keys: %i[open_round_bracket close_round_bracket array_operand operand monomial],
          stack_type: :open_bracket
        },
        close_round_bracket: {
          regex: CLOSE_ROUND_BRACKET_REGEX,
          next_regex_keys: %i[operator close_round_bracket],
          stack_type: :close_bracket
        },
        monomial: {
          regex: MONOMIAL_REGEX,
          next_regex_keys: %i[open_round_bracket],
          stack_type: :monomial
        },
        monomial_open_round_bracket: {
          regex: MONOMIAL_REGEX_OPEN_ROUND_BRACKET,
          next_regex_keys: %i[array_operand operand],
          stack_type: :monomial_open_round_bracket
        }
      }.freeze

      class << self
        # rubocop:disable Metrics/PerceivedComplexity
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/AbcSize
        def to_postfix(infix_expression)
          stack = []
          postfix_stack = []
          remaining_characters = infix_expression

          raise 'expression cannot end with an operand' if infix_expression.match? INVALID_REGEX

          regex_keys = REGEXES[:start][:next_regex_keys]
          # rubocop:disable Metrics/BlockNesting
          until remaining_characters.blank?
            matched_regex_key = regex_keys
              .select { |regex_key| remaining_characters.match? REGEXES[regex_key][:regex] }
              .first

            raise "Failed to traverse '#{infix_expression}'" if matched_regex_key.blank?

            matched_regex = REGEXES[matched_regex_key][:regex]
            match = remaining_characters.match(matched_regex)

            regex_keys = REGEXES[matched_regex_key][:next_regex_keys]
            stack_type = REGEXES[matched_regex_key][:stack_type]

            case stack_type
            when :monomial
              remaining_characters = remaining_characters.sub(matched_regex, "(0 #{match[1]} #{match[2]})")

              next
            when :monomial_open_round_bracket
              remaining_characters = remaining_characters.sub(matched_regex, "0 #{match[1]} #{match[2]}")

              next
            end

            case stack_type
            when :open_bracket
              stack << OPEN_ROUND_BRACKET
            when :stack
              new_operator = match[1]

              # Move existing operators out of stack unless they have
              # higher priority
              while stack.any? && OPERATORS.include?(stack[-1])
                stack_operator = stack.pop

                if compare_operator_priority(new_operator, stack_operator)
                  stack << stack_operator

                  break
                else
                  # Move existing operator from stack to postfix_stack
                  # If new_operator has lower or same priority
                  postfix_stack << stack_operator
                end
              end
              stack << new_operator
            when :postfix_stack
              postfix_stack << match[1]
            when :close_bracket
              temp_stack = []
              popped_value = ''
              while stack.any? && (popped_value = stack.pop) != OPEN_ROUND_BRACKET
                temp_stack << popped_value
              end
              if popped_value != OPEN_ROUND_BRACKET
                raise "Could not find matching '#{OPEN_ROUND_BRACKET}' in '#{infix_expression}'"
              end

              temp_stack = temp_stack.reverse
              while temp_stack.any? && (temp_value = temp_stack.pop)
                postfix_stack << temp_value
              end
            else
              raise "Incorrect :stack_type for regex_key '#{regex_key}'"
            end

            remaining_characters = remaining_characters.sub(match[0], '')
          end
          # rubocop:enable Metrics/BlockNesting

          raise 'bracket was not closed' if stack.include? OPEN_ROUND_BRACKET

          postfix_stack << stack.pop while stack.any?

          postfix_stack.join(' ')
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/PerceivedComplexity

        private

        def compare_operator_priority(first_operator, second_operator)
          OPERATOR_PRIORITY[first_operator] > OPERATOR_PRIORITY[second_operator]
        end
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
