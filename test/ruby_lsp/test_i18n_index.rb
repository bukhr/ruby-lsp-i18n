# typed: true
# frozen_string_literal: true

require "test_helper"
require "yaml"
require "ruby_lsp/ruby_lsp_i18n/i18n_index"
module RubyLsp
  module RubyLspI18n
    class I18nIndexTest < Minitest::Test
      #: () -> untyped
      def setup
        @db = I18nIndex.new(language: "es")
      end

      #: () -> untyped
      def teardown
        fixture_files = Dir["test/fixtures/**/*.yml"]
        fixture_files.each do |file|
          File.delete(file) if File.exist?(file)
        end
      end

      #: () -> untyped
      def test_find_entry
        File.open("test/fixtures/es.yml", "w") do |f|
          f.write(YAML.dump({ "es" => { "foo" => "bar" } }))
        end

        @db.sync_file("test/fixtures/es.yml")

        assert_equal(1, @db.find("foo").size)
        entrie = @db.find("foo").first
        assert_equal("bar", entrie.value)
        assert_equal("test/fixtures/es.yml", entrie.file)
      end

      #: () -> untyped
      def test_sync_file_new_file
        File.open("test/fixtures/new_es.yml", "w") do |f|
          f.write(YAML.dump({ "es" => { "foo" => "bar" } }))
        end

        @db.sync_file("test/fixtures/new_es.yml")

        assert_equal(1, @db.find("foo").size)
        entrie = @db.find("foo").first
        assert_equal("bar", entrie.value)
        assert_equal("test/fixtures/new_es.yml", entrie.file)
      end

      #: () -> untyped
      def test_sync_file_invalid_yaml
        @db.sync_file("test/fixtures/invalid_es.yml")
        assert_empty(@db.find("foo"))
      end

      #: () -> untyped
      def test_sync_file_empty_yaml
        File.open("test/fixtures/empty_es.yml", "w") do |f|
          f.write(YAML.dump({ "es" => {} }))
        end
        @db.sync_file("test/fixtures/empty_es.yml")
        assert_empty(@db.find("foo"))

        File.open("test/fixtures/empty_es.yml", "w") do |f|
          f.write("")
        end
        @db.sync_file("test/fixtures/empty_es.yml")
        assert_empty(@db.find("foo"))
      end

      #: () -> untyped
      def test_file_sync_file_change_value
        File.open("test/fixtures/es.yml", "w") do |f|
          f.write(YAML.dump({ "es" => { "foo" => "baz" } }))
        end
        @db.sync_file("test/fixtures/es.yml")

        File.open("test/fixtures/es.yml", "w") do |f|
          f.write(YAML.dump({ "es" => { "foo" => "bar" } }))
        end

        @db.sync_file("test/fixtures/es.yml")

        assert_equal(1, @db.find("foo").size)
        entrie = @db.find("foo").first
        assert_equal("bar", entrie.value)
        assert_equal("test/fixtures/es.yml", entrie.file)
      end

      #: () -> untyped
      def test_file_sync_change_key
        File.open("test/fixtures/es.yml", "w") do |f|
          f.write(YAML.dump({ "es" => { "baz" => "bar" } }))
        end
        @db.sync_file("test/fixtures/es.yml")

        File.open("test/fixtures/es.yml", "w") do |f|
          f.write(YAML.dump({ "es" => { "foo" => "bar" } }))
        end

        @db.sync_file("test/fixtures/es.yml")

        assert_equal(1, @db.find("foo").size)
        entrie = @db.find("foo").first
        assert_equal("bar", entrie.value)
        assert_equal("test/fixtures/es.yml", entrie.file)
      end

      #: () -> untyped
      def test_file_sync_delete_key
        File.open("test/fixtures/es.yml", "w") do |f|
          f.write(YAML.dump({ "es" => { "foo" => "bar" } }))
        end
        @db.sync_file("test/fixtures/es.yml")

        File.open("test/fixtures/es.yml", "w") do |f|
          f.write(YAML.dump({ "es" => {} }))
        end

        @db.sync_file("test/fixtures/es.yml")

        assert_empty(@db.find("foo"))
      end

      #: () -> untyped
      def test_file_sync_delete_file
        File.open("test/fixtures/es.yml", "w") do |f|
          f.write(YAML.dump({ "es" => { "foo" => "bar" } }))
        end
        @db.sync_file("test/fixtures/es.yml")

        assert_equal(1, @db.find("foo").size)
        entrie = @db.find("foo").first
        assert_equal("bar", entrie.value)
        assert_equal("test/fixtures/es.yml", entrie.file)

        File.delete("test/fixtures/es.yml")
        @db.sync_file("test/fixtures/es.yml")

        assert_empty(@db.find("foo"))
      end
    end
  end
end
