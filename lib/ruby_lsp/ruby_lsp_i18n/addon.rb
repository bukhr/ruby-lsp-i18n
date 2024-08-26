# frozen_string_literal: true

require "ruby_lsp/addon"
require_relative "listeners/inlay_hints"
require_relative "requests/inlay_hints"
require_relative "i18n_database"

module RubyLsp
  module RubyLspI18n
    GLOB_PATH = "**/config/locales/**/*.yml"
    # This class is the entry point for the addon. It is responsible for activating and deactivating the addon
    class Addon < ::RubyLsp::Addon
      def initialize
        super
        @i18n_database = I18nDatabase.new
        @i18n_database.start
      end

      # Performs any activation that needs to happen once when the language server is booted
      def activate(global_state, message_queue)
        @message_queue = message_queue

        @message_queue << Request.new(
          id: "ruby-lsp-my-gem-file-watcher",
          method: "client/registerCapability",
          params: Interface::RegistrationParams.new(
            registrations: [
              Interface::Registration.new(
                id: "workspace/didChangeWatchedFilesMyGem",
                method: "workspace/didChangeWatchedFiles",
                register_options: Interface::DidChangeWatchedFilesRegistrationOptions.new(
                  watchers: [
                    Interface::FileSystemWatcher.new(
                      glob_pattern: GLOB_PATH,
                      kind: Constant::WatchKind::CREATE | Constant::WatchKind::CHANGE | Constant::WatchKind::DELETE,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      end

      # Performs any cleanup when shutting down the server, like terminating a subprocess
      def deactivate; end

      def workspace_did_change_watched_files(changes)
        changes.each do |change|
          uri = change.dig(:uri)
          next unless uri
          next unless uri.end_with?("es.yml")

          uri = URI.parse(uri).path.gsub(Dir.pwd + "/", "")
          @i18n_database.update_file(uri)
        end
      end

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
