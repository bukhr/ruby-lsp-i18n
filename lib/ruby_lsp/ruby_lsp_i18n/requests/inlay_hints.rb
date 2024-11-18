# typed: strict
# frozen_string_literal: true

# Moneky patch overrifing the InlayHints Initializer
# to support addons for InlayHints in the ruby lsp.
module RubyLsp
  module Requests
    class InlayHints < Request
      def initialize(document, hints_configuration, dispatcher)
        super()

        @response_builder = T.let(
          ResponseBuilders::CollectionResponseBuilder[Interface::InlayHint].new,
          ResponseBuilders::CollectionResponseBuilder[Interface::InlayHint],
        )
        Listeners::InlayHints.new(@response_builder, hints_configuration, dispatcher)

        Addon.addons.each do |addon|
          if addon.respond_to?(:create_inlay_hints_listener)
            addon.create_inlay_hints_listener(@response_builder, dispatcher, document)
          end
        end
      end
    end
  end
end
