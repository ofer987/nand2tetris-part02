# frozen_string_literal: true

module JackCompiler
  class IfNode < Node
    REGEX = RegularExpressions::IF_STATEMENT_REGEX
    NODE_NAME = Statement::IF_STATEMENT

    def initialize(xml_node)
      super(xml_node)

      init_code
    end

    def emit_vm_code
      if statements.size > 1
        emit_if_else_code
      else
        emit_if_code
      end
    end

    def emit_if_else_code
      # Store as lines in an array
      result = <<~VM_CODE
        #{expression}
        not
        if-goto #{else_label}
        #{if_statements}
        GOTO #{continue_label}
        (#{else_label})
        #{else_statements}
        #{continue_label}
      VM_CODE

      result.split("\n")
    end

    def emit_if_code
      # Store as lines in an array
      result = <<~VM_CODE
        #{expression}
        not
        if-goto #{continue_label}
        #{if_statements}
        #{continue_label}
      VM_CODE

      result.split("\n")
    end

    protected

    def init_code
      @statements = find_child_nodes(Statement::STATEMENTS_STATEMENT)

      @if_statements = statements[0]
      @else_statements = statements[1]
    end

    private

    def expression
      ''
    end

    def continue_label
      @continue_label ||= "CONTINUE_LABEL_#{uuid}"
    end

    def else_label
      @else_label ||= "ELSE_LABEL_#{uuid}"
    end

    def uuid
      @uuid ||= SecureRandom.uuid
    end

    attr_reader :statements, :if_statements, :else_statements
  end
end
