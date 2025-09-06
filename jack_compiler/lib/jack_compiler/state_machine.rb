# frozen_string_literal: true

module JackCompiler
  class StateMachine
    LINE_COMMENT = %r{//.+$}
    BEGIN_COMMENT_BLOCK = %r{/\*}
    END_COMMENT_BLOCK = %r{\*/}

    attr_reader :statements

    def document
      return @document if defined? @document

      @document = Nokogiri::XML::Document.new
    end

    def initialize(path)
      lines = File.readlines(path)
        .map(&:chomp)
        .map(&:strip)
        .map { |line| line.gsub(LINE_COMMENT, '') }
        .reject(&:blank?)

      self.statements = lines
    end

    def parse
      class_statement = ClassStatement.new(document)
      class_statement.create_elements(document, statements)
    end

    private

    def statements=(lines)
      results = []

      is_comment_block = false
      lines.each do |line|
        is_comment_block = true if line.match? BEGIN_COMMENT_BLOCK

        if line.match?(END_COMMENT_BLOCK)
          is_comment_block = false

          next
        end

        results << line unless is_comment_block
      end

      @statements = results.join
    end
  end
end
