# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "ruby_lsp/i18n"

require "minitest/autorun"
require "ruby_lsp/internal"
require "ruby_lsp/test_helper"
require "ruby_lsp/ruby_lsp_i18n/i18n_database"

def assert_same_elements(expected, actual)
  assert_equal(expected.size, actual.size)
  expected.each do |e|
    assert_includes(actual, e)
  end
rescue Minitest::Assertion
  assert_equal(expected, actual)
end
