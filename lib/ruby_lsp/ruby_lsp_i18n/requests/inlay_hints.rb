# frozen_string_literal: true

# Moneky patch overrifing the InlayHints Initializer
# to support addons for InlayHints in the ruby lsp.
module RubyLsp
  module Requests
    class InlayHints < Request
      def initialize(document, range, hints_configuration, dispatcher)
        super()
        start_line = range.dig(:start, :line)
        end_line = range.dig(:end, :line)

        @response_builder = T.let(
          ResponseBuilders::CollectionResponseBuilder[Interface::InlayHint].new,
          ResponseBuilders::CollectionResponseBuilder[Interface::InlayHint],
        )
        Listeners::InlayHints.new(@response_builder, start_line..end_line, hints_configuration, dispatcher)

        Addon.addons.each do |addon|
          addon.create_inlay_hints_listener(@response_builder, start_line..end_line, hints_configuration, dispatcher)
        end
      end
    end
  end
end
