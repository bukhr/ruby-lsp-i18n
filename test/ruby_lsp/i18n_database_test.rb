# frozen_string_literal: true

require "test_helper"

module RubyLsp
  module RubyLspI18n
    class I18nDatabaseTest < Minitest::Test
      def setup
        @db = I18nDatabase.new(language: "es")
      end

      def teardown
        fixture_files = Dir["test/fixtures/**/*.yml"]
        fixture_files.each do |file|
          File.delete(file) if File.exist?(file)
        end
      end

      def test_find_entry
        File.open("test/fixtures/es.yml", "w") do |f|
          f.write({ "es" => { "foo" => "bar" } }.to_yaml)
        end

        @db.sync_file("test/fixtures/es.yml")

        assert_equal(
          [{ value: "bar", file: "test/fixtures/es.yml" }],
          @db.find("foo"),
        )
      end

      def test_sync_file_new_file
        File.open("test/fixtures/new_es.yml", "w") do |f|
          f.write({ "es" => { "foo" => "bar" } }.to_yaml)
        end

        @db.sync_file("test/fixtures/new_es.yml")

        assert_equal(
          [{ value: "bar", file: "test/fixtures/new_es.yml" }],
          @db.find("foo"),
        )

        File.delete("test/fixtures/new_es.yml")
      end

      def test_sync_file_invalid_yaml
        @db.sync_file("test/fixtures/invalid_es.yml")
      end

      def test_sync_file_empty_yaml
        File.open("test/fixtures/empty_es.yml", "w") do |f|
          f.write({ "es" => {} }.to_yaml)
        end
        @db.sync_file("test/fixtures/empty_es.yml")

        File.open("test/fixtures/empty_es.yml", "w") do |f|
          f.write("")
        end

        @db.sync_file("test/fixtures/empty_es.yml")
      end

      def test_file_sync_file_change_value
        File.open("test/fixtures/es.yml", "w") do |f|
          f.write({ "es" => { "foo" => "baz" } }.to_yaml)
        end
        @db.sync_file("test/fixtures/es.yml")

        File.open("test/fixtures/es.yml", "w") do |f|
          f.write({ "es" => { "foo" => "bar" } }.to_yaml)
        end

        @db.sync_file("test/fixtures/es.yml")

        assert_equal(
          [{ value: "bar", file: "test/fixtures/es.yml" }],
          @db.find("foo"),
        )
      end

      def test_file_sync_change_key
        File.open("test/fixtures/es.yml", "w") do |f|
          f.write({ "es" => { "baz" => "bar" } }.to_yaml)
        end
        @db.sync_file("test/fixtures/es.yml")

        File.open("test/fixtures/es.yml", "w") do |f|
          f.write({ "es" => { "foo" => "bar" } }.to_yaml)
        end

        @db.sync_file("test/fixtures/es.yml")

        assert_equal(
          [{ value: "bar", file: "test/fixtures/es.yml" }],
          @db.find("foo"),
        )
      end

      def test_file_sync_delete_key
        File.open("test/fixtures/es.yml", "w") do |f|
          f.write({ "es" => { "foo" => "bar" } }.to_yaml)
        end
        @db.sync_file("test/fixtures/es.yml")

        File.open("test/fixtures/es.yml", "w") do |f|
          f.write({ "es" => {} }.to_yaml)
        end

        @db.sync_file("test/fixtures/es.yml")

        assert_equal(
          [],
          @db.find("foo"),
        )
      end

      def test_file_sync_delete_file
        File.open("test/fixtures/es.yml", "w") do |f|
          f.write({ "es" => { "foo" => "bar" } }.to_yaml)
        end
        @db.sync_file("test/fixtures/es.yml")
        assert_equal(
          [{ value: "bar", file: "test/fixtures/es.yml" }],
          @db.find("foo"),
        )
        File.delete("test/fixtures/es.yml")
        @db.sync_file("test/fixtures/es.yml")

        assert_equal(
          [],
          @db.find("foo"),
        )
      end
    end
  end
end
