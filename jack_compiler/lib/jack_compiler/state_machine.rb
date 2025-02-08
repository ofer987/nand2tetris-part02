# frozen_string_literal: true

module JackCompiler
  class StateMachine
    def document
      return @document if defined? @document

      @document = Nokogiri::XML::Document.new
    end

    def initialize(path)
      @statements = File.readlines(path)
        .map(&:chomp)
        .map(&:strip)
        .join
    end

    def parse
      parsed_statements = @statements

      until parsed_statements.blank?
        if parsed_statements.match? JackCompiler::RegularExpressions::IF
          if_statement(document, JackCompiler::RegularExpressions::IF, parsed_statements)
        elsif parsed_statements.match? JackCompiler::RegularExpressions::CLASS
          class_statement(document, JackCompiler::RegularExpressions::CLASS,  parsed_statements)
      end
    end

    private

    def class_statement(document, regex, parsed_statements)
      result = parsed_statements.match(regex)
      class_node = document.create_element('class')

      document << class_node

      keyword_node = document.create_element('keyword', 'class')
      class_node << keyword_node

      class_name_node = document.create_element('identifier', result[1])
      class_node << class_name_node
    end

    def if_statement(document, parsed_statements)
    end

    attr_writer :statements
  end
end
