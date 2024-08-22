# frozen_string_literal: true

require "test_helper"

module RubyLsp
  class TestRubyLspI18n < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil(RubyLsp::RubyLspI18n::VERSION)
    end
  end
end
