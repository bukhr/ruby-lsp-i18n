# typed: true
# frozen_string_literal: true

# Moneky patch overrifing the InlayHints Initializer
# to support addons for InlayHints in the ruby lsp.
module RubyLsp
  module Requests
    module InlayHintsPatch
      # @requires_ancestor: Kernel
      #: (RubyLsp::GlobalState, RubyDocument | ERBDocument, Prism::Dispatcher) -> void
      def initialize(global_state, document, dispatcher)
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
