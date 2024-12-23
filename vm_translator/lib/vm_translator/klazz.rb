# frozen_string_literal: true

module VMTranslator
  class Klazz
    attr_reader :name, :body

    def self.initialize_from_file(filename)
      basename = File.basename(filename)
      extension = File.extname(basename)

      name = basename.gsub(extension, '')
      body = File.readlines(filename)
        .map(&:strip)
        .reject { |line| line.start_with? '//' }
        .reject(&:empty?)
        .join("\n")

      Klazz.new(name, body)
    end

    def initialize(name, body)
      @name = name.to_s
      @body = body.to_s
    end
  end
end
