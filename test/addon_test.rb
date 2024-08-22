# typed: true
# frozen_string_literal: true

require "test_helper"

class I18nAddonTest < Minitest::Test
  def test_foo_class_hint
    document = RubyLsp::RubyDocument.new(uri: URI("file://foo.rb"), source: <<~RUBY, version: 1)
      I18n.t("hello.world")
    RUBY

    dispatcher = Prism::Dispatcher.new
    hints_configuration = RubyLsp::RequestConfig.new({ enableAll: true })
    request = RubyLsp::Requests::InlayHints.new(document, default_args.first, hints_configuration, dispatcher)
    dispatcher.dispatch(document.tree)
    assert_equal([{ label: "hello.world", position: { line: 0, character: 5 }, padding_left: true, tooltip: "This is a class definition" }], request.perform)
  end
end
