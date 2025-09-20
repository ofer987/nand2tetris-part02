# frozen_string_literal: true

module JackCompiler
  class ClassNode < Node
    REGEX = RegularExpressions::CLASS
    NODE_NAME = Statement::CLASS

    attr_reader :file_name

    def initialize(xml_node)
      super(xml_node)

      result = lines.match(REGEX)
      @file_name = result[1]
    end

    def emit_vm_code
      ''
    end
  end
end
