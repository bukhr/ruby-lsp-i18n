# typed: true
# frozen_string_literal: true

# Moneky patch overrifing the InlayHints Initializer
# to support addons for InlayHints in the ruby lsp.
module RubyLsp
  module Requests
    module InlayHintsPatch
      extend T::Sig
      extend T::Helpers

      requires_ancestor { InlayHints }

      sig do
        params(
          document: T.any(RubyDocument, ERBDocument),
          hints_configuration: RequestConfig,
          dispatcher: Prism::Dispatcher,
        ).void
      end
      def initialize(document, hints_configuration, dispatcher)
        super

        Addon.addons.each do |addon|
          next unless addon.respond_to?(:create_inlay_hints_listener)

          addon.create_inlay_hints_listener(@response_builder, dispatcher, document)
        end
      end
    end

    class InlayHints
      prepend InlayHintsPatch
    end
  end
end
