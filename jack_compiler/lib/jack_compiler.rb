# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'
require 'nokogiri'
require 'securerandom'
require 'rspec'

require_relative 'jack_compiler/utils/xml'
require_relative 'jack_compiler/regular_expressions'

# Generate the Abstract Syntax Tree (AST)
require_relative 'jack_compiler/memory_scope'
require_relative 'jack_compiler/statement'
require_relative 'jack_compiler/parameters_statement'
require_relative 'jack_compiler/open_brace_statement'
require_relative 'jack_compiler/close_brace_statement'
require_relative 'jack_compiler/class_statement'
require_relative 'jack_compiler/array_expression_statement'
require_relative 'jack_compiler/let_statement'
require_relative 'jack_compiler/expression_statement'
require_relative 'jack_compiler/infix_expression_statement'
require_relative 'jack_compiler/unary_assignment_statement'
require_relative 'jack_compiler/binary_assignment_statement_01'
require_relative 'jack_compiler/binary_assignment_statement_02'
require_relative 'jack_compiler/binary_assignment_statement_03'
require_relative 'jack_compiler/binary_assignment_statement_04'
require_relative 'jack_compiler/array_assignment_statement'
require_relative 'jack_compiler/boolean_assignment_statement'
require_relative 'jack_compiler/variable_assignment_statement'
require_relative 'jack_compiler/string_assignment_statement'
require_relative 'jack_compiler/integer_assignment_statement'
require_relative 'jack_compiler/null_assignment_statement'
require_relative 'jack_compiler/variable_assignment_statement'
require_relative 'jack_compiler/execution_expression_statement'
require_relative 'jack_compiler/operation_assignment_statement'
require_relative 'jack_compiler/if_statement'
require_relative 'jack_compiler/else_statement'
require_relative 'jack_compiler/class_variable_statement'
require_relative 'jack_compiler/class_subroutine_statement'
require_relative 'jack_compiler/subroutine_body_statement'
require_relative 'jack_compiler/variable_statement'
require_relative 'jack_compiler/do_statement'
require_relative 'jack_compiler/return_statement'
require_relative 'jack_compiler/empty_return_statement'
require_relative 'jack_compiler/assignment_expression_statement'
require_relative 'jack_compiler/argument_statement'
require_relative 'jack_compiler/statements_statement'

# Infix and Postfix calculator and utilities
require_relative './jack_compiler/postfix_calculator'
require_relative './jack_compiler/utils/infix'

# Traverse the Abstract Syntax Tree (AST)
require_relative 'jack_compiler/node'

## Expression nodes
require_relative 'jack_compiler/boolean_expression'
require_relative 'jack_compiler/null_assignment_expression'
require_relative 'jack_compiler/execution_expression'
require_relative 'jack_compiler/string_assignment_expression'
require_relative 'jack_compiler/integer_assignment_expression'
require_relative 'jack_compiler/infix_evaluator_expression'
require_relative 'jack_compiler/expression_node'

require_relative 'jack_compiler/if_node'

require_relative 'jack_compiler/memory'
require_relative 'jack_compiler/primitive_memory'
require_relative 'jack_compiler/class_memory'
require_relative 'jack_compiler/array_memory'

# NOTE: An **ExpressionListNode** is _not_ an **ExpressionNode**!
require_relative 'jack_compiler/expression_list_node'
require_relative 'jack_compiler/memory_node'
require_relative 'jack_compiler/variable_node'
require_relative 'jack_compiler/var_statement_node'
require_relative 'jack_compiler/class_variable_node'
require_relative 'jack_compiler/class_node'
require_relative 'jack_compiler/statement_node'
require_relative 'jack_compiler/parameter_variable_node'
require_relative 'jack_compiler/function_node'
require_relative 'jack_compiler/method_node'
require_relative 'jack_compiler/let_statement_node'
require_relative 'jack_compiler/do_statement_node'
require_relative 'jack_compiler/return_node'

require_relative 'jack_compiler/version'
require_relative 'jack_compiler/state_machine'

module JackCompiler
  class Error < StandardError; end
end
