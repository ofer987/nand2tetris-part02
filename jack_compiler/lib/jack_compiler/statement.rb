# frozen_string_literal: true

module JackCompiler
  class Statement
    attr_reader :document

    def initialize(document)
      @document = document
    end

    def create_elements(document, parent_element)
      raise NotImplementedError
    end

    def next_statements
      raise NotImplementedError
    end
  end
end
