# frozen_string_literal: true

require_relative "lib/ruby_lsp_i18n/version"

Gem::Specification.new do |spec|
  spec.name = "ruby-lsp-i18n"
  spec.version = RubyLsp::RubyLspI18n::VERSION
  spec.authors = ["domingo2000"]
  spec.email = ["dedwards@buk.cl"]

  spec.summary = "Gives support for i18n in Ruby LSP"
  spec.description = "Gives support for i18n in Ruby LSP"
  spec.homepage = "https://github.com/bukhr/ruby-lsp-i18n"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bukhr/ruby-lsp-i18n"
  spec.metadata["changelog_uri"] = "https://github.com/bukhr/ruby-lsp-i18n/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    %x(git ls-files -z).split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?("bin/", "test/", "spec/", "features/", ".git", ".github", "appveyor", "Gemfile")
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
