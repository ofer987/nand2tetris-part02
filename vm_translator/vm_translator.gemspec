# frozen_string_literal: true

require_relative 'lib/vm_translator/version'

Gem::Specification.new do |spec|
  spec.name = 'vm_translator'
  spec.version = VMTranslator::VERSION
  spec.authors = ['Dan Jakob Ofer']
  spec.email = ['dan@ofer.to']

  spec.summary = 'Translate VM Hack to Assembly Hack'
  spec.required_ruby_version = '>= 3.1.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
