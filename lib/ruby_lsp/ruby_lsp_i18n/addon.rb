# frozen_string_literal: true

require "ruby_lsp/addon"
require_relative "listeners/inlay_hints"
require_relative "requests/inlay_hints"
require_relative "i18n_database"

module RubyLsp
  module RubyLspI18n
    # This class is the entry point for the addon. It is responsible for activating and deactivating the addon
    class Addon < ::RubyLsp::Addon
      def initialize
        super
        @i18n_database = I18nDatabase.new
      end

      # Performs any activation that needs to happen once when the language server is booted
      def activate(global_state, message_queue)
      end

      # Performs any cleanup when shutting down the server, like terminating a subprocess
      def deactivate; end

      # Returns the name of the addon
      def name
        "Ruby LSP I18n"
      end

      def create_inlay_hints_listener(response_builder, range, hints_configuration, dispatcher)
        InlayHints.new(@i18n_database, response_builder, range, hints_configuration, dispatcher)
      end
    end
  end
end
