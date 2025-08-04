# frozen_string_literal: true

module JackCompiler
  class ExpressionStatement < Statement
    def create_elements(_parent_node, _lines)
      throw NotImplementedError
    end

    protected

    def next_classes
      throw NotImplementedError
    end
  end
end
