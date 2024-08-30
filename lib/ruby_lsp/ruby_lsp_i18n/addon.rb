# typed: strict
# frozen_string_literal: true

require "ruby_lsp/addon"
require_relative "requests/inlay_hints"
require_relative "listeners/inlay_hints"
require_relative "listeners/completion"
require_relative "i18n_database"

module RubyLsp
  module RubyLspI18n
    GLOB_PATH = "**/config/locales/**/es.yml"
    # This class is the entry point for the addon. It is responsible for activating and deactivating the addon
    class Addon < ::RubyLsp::Addon
      extend T::Sig

      sig { void }
      def initialize
        super
        @i18n_database = T.let(I18nDatabase.new(language: "es"), I18nDatabase)

        files = Dir[GLOB_PATH]
        files.each do |file|
          @i18n_database.sync_file(file)
        end
      end

      # Performs any activation that needs to happen once when the language server is booted)}
      sig { override.params(global_state: RubyLsp::GlobalState, message_queue: Thread::Queue).void }
      def activate(global_state, message_queue)
        message_queue << Request.new(
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
      sig { override.void }
      def deactivate; end

      sig { params(changes: T::Array[T::Hash[Symbol, T.untyped]]).void }
      def workspace_did_change_watched_files(changes)
        changes.each do |change|
          change = Interface::FileEvent.new(uri: change[:uri], type: change[:type])
          uri = T.let(change.uri, String)

          next unless uri.end_with?("es.yml")

          path = URI.parse(uri).path

          next if path.nil?

          path = path.gsub(Dir.pwd + "/", "")
          @i18n_database.sync_file(path)
        end
      end

      # Returns the name of the addon
      sig { override.returns(String) }
      def name
        "Ruby LSP I18n"
      end

      sig do
        params(
          response_builder: ResponseBuilders::CollectionResponseBuilder[Interface::InlayHint],
          dispatcher: Prism::Dispatcher,
          document: T.any(RubyDocument, ERBDocument),
        ).void
      end
      def create_inlay_hints_listener(response_builder, dispatcher, document)
        InlayHints.new(@i18n_database, response_builder, dispatcher, document)
      end

      sig do
        override.params(
          response_builder: RubyLsp::ResponseBuilders::CollectionResponseBuilder[LanguageServer::Protocol::Interface::CompletionItem],
          node_context: RubyLsp::NodeContext,
          dispatcher: Prism::Dispatcher,
          uri: URI::Generic,
        ).void
      end
      def create_completion_listener(response_builder, node_context, dispatcher, uri)
        Completion.new(@i18n_database, response_builder, dispatcher)
      end
    end
  end
end

# Patch the InlayHints request to support addons
module RubyLsp
  class Addon
    extend T::Sig
    sig do
      params(
        response_builder: ResponseBuilders::CollectionResponseBuilder[Interface::InlayHint],
        dispatcher: Prism::Dispatcher,
        document: T.any(RubyDocument, ERBDocument),
      ).void
    end
    def create_inlay_hints_listener(response_builder, dispatcher, document)
    end
  end
end
