# frozen_string_literal: true

require "test_helper"

module RubyLsp
  module RubyLspI18n
    class I18nDatabaseTest < Minitest::Test
      def setup
        @db = I18nDatabase.new
      end

      def test_add_entry
        @db.add("foo.bar", "foo bar", "qux/en.yml")
        @db.add("foo.bar", "foo baz", "baz/en.yml")
        assert_equal(
          [{ value: "foo bar", file: "qux/en.yml" }, { value: "foo baz", file: "baz/en.yml" }],
          @db.find("foo.bar"),
        )
      end

      def test_remove_entry
        @db.add("foo.bar", "foo bar", "qux/en.yml")
        @db.add("foo.bar", "foo baz", "baz/en.yml")

        @db.remove("foo.bar", "qux/en.yml")
        @db.remove("baz", "baz/en.yml") # If key does not exist do nothing
        assert_equal(
          [{ value: "foo baz", file: "baz/en.yml" }],
          @db.find("foo.bar"),
        )
      end

      def test_update_entry
        @db.add("foo.bar", "foo bar", "qux/en.yml")
        @db.add("foo.bar", "foo baz", "baz/en.yml")
        @db.update("foo.bar", "bar foo", "qux/en.yml")
        assert_same_elements(
          [{ value: "bar foo", file: "qux/en.yml" }, { value: "foo baz", file: "baz/en.yml" }],
          @db.find("foo.bar"),
        )
      end

      def test_update_entry_from_different_file
        @db.add("foo.bar", "foo bar", "qux/en.yml")
        @db.update("foo.bar", "bar foo", "baz/en.yml")
        assert_equal(
          [
            { value: "foo bar", file: "qux/en.yml" },
            { value: "bar foo", file: "baz/en.yml" },
          ],
          @db.find("foo.bar"),
        )
      end

      def test_find_entry
        @db.add("foo.bar", "foo bar", "qux/en.yml")
        @db.add("foo.bar", "foo baz", "baz/en.yml")
        assert_equal(
          [{ value: "foo bar", file: "qux/en.yml" }, { value: "foo baz", file: "baz/en.yml" }],
          @db.find("foo.bar"),
        )
        assert_equal(
          [],
          @db.find("baz"),
        )
      end

      def test_load_file
        @db.load_file("test/fixtures/es.yml")
        assert_equal(
          [{ value: "bar", file: "test/fixtures/es.yml" }],
          @db.find("foo.bar"),
        )

        assert_equal(
          [{ value: "baz", file: "test/fixtures/es.yml" }],
          @db.find("baz"),
        )
      end

      def test_load_keys_invalid_yaml
        assert_silent do
          @db.load_file("test/fixtures/invalid.yml")
        end
      end

      def test_start
        @db.instance_variable_set(:@translation_path, "test/fixtures/**/*es.yml")
        @db.start

        assert_same_elements(
          [
            { value: "bar a", file: "test/fixtures/a/es.yml" },
            { value: "bar", file: "test/fixtures/es.yml" },
          ],
          @db.find("foo.bar"),
        )
        assert_same_elements(
          [{ value: "baz", file: "test/fixtures/es.yml" }],
          @db.find("baz"),
        )
        assert_same_elements(
          [{ value: "qux", file: "test/fixtures/a/es.yml" }],
          @db.find("qux"),
        )
      end

      def test_update_file
        YAML.stub(:load_file, { "es" => { "foo" => "bar" } }) do
          @db.load_file("test/fixtures/es.yml")
          assert_equal(
            [{ value: "bar", file: "test/fixtures/es.yml" }],
            @db.find("foo"),
          )
        end

        YAML.stub(:load_file, { "es" => { "foo" => "baz" } }) do
          @db.update_file("test/fixtures/es.yml")
          assert_equal(
            [{ value: "baz", file: "test/fixtures/es.yml" }],
            @db.find("foo"),
          )
        end
      end

      def test_delete_file
        @db.load_file("test/fixtures/es.yml")
        @db.delete_file("test/fixtures/es.yml")
        assert_equal(
          [],
          @db.find("foo.bar"),
        )
        assert_equal(
          [],
          @db.find("baz"),
        )
      end
    end
  end
end
