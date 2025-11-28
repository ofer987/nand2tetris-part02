# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  primary_coverage :line
  minimum_coverage 65

  add_filter do |src|
    src.filename.match?(/_node\.rb$/) ||
      src.filename.match?(/_statement\.rb$/) ||
      src.filename.match?(/_statement_\d{2}\.rb/)
  end
end
