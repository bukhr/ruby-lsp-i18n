# typed: true
# frozen_string_literal: true

require "test_helper"

class I18nAddonTest < Minitest::Test
  include RubyLsp::TestHelper

  def setup
    @uri = URI("file:///foo.rb")
    yaml = <<~YAML
      es:
        test:
          addon: "Test Addon"
          bar: "Test Bar"
        other:
          key: "Other Key"

    YAML

    File.open("test/fixtures/config/locales/es.yml", "w") do |f|
      f.puts(yaml)
    end
  end

  def teardown
    File.delete("test/fixtures/config/locales/es.yml")
  end

  def test_addon_inlay_hint
    source = <<~RUBY
      I18n.t("test.addon")
    RUBY

    with_server(source, @uri) do |server, uri|
      # First we get the response for the file watcher
      server.pop_response

      # Then we get the response for the inlay hint
      server.process_message({
        id: 1,
        method: "textDocument/inlayHint",
        params: {
          textDocument: {
            uri: uri,
          },
          range: {
            start: { line: 0, character: 0 },
          },
        },
      })
      result = server.pop_response.response
      inlay_hint = result.first

      tooltip_content = "**Translations (es)**\n" + "- [test/fixtures/config/locales/es.yml](file://#{Dir.pwd}/test/fixtures/config/locales/es.yml): Test Addon\n"
      assert_equal("Test Addon", inlay_hint.label)

      assert_equal(inlay_hint.tooltip.kind, "markdown")
      assert_equal(inlay_hint.tooltip.value, tooltip_content)
    end
  end

  def test_addon_autocomplete
    source = <<~RUBY
      I18n.t("test")
    RUBY

    with_server(source, @uri) do |server, uri|
      server.pop_response
      # Finally we get the response for autocomplete
      server.process_message({
        id: 2,
        method: "textDocument/completion",
        params: {
          textDocument: {
            uri: uri,
          },
          position: { line: 0, character: 8 },
        },
      })

      result = server.pop_response.response
      assert_equal(2, result.length)

      assert_equal('"test.addon"', result[0].label)
      assert_equal('"test.addon"', result[0].detail.inspect)
      assert_equal('"test.addon"', result[0].text_edit.new_text)
      assert_equal(0, result[0].text_edit.range.start.line)
      assert_equal(7, result[0].text_edit.range.start.character)
      assert_equal(0, result[0].text_edit.range.end.line)
      assert_equal(13, result[0].text_edit.range.end.character)

      assert_equal('"test.bar"', result[1].label)
      assert_equal('"test.bar"', result[1].detail.inspect)
      assert_equal(0, result[1].text_edit.range.start.line)
      assert_equal(7, result[1].text_edit.range.start.character)
      assert_equal(0, result[1].text_edit.range.end.line)
      assert_equal(13, result[1].text_edit.range.end.character)
    end
  end
end
