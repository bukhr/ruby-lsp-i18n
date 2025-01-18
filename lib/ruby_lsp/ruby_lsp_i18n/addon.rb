# typed: strict
# frozen_string_literal: true

require "ruby_lsp/addon"
require_relative "requests/inlay_hints"
require_relative "listeners/inlay_hints"
require_relative "listeners/completion"
require_relative "i18n_index"
require_relative "../../ruby_lsp_i18n/version"

RubyLsp::Addon.depend_on_ruby_lsp!("~> 0.23.0")

module RubyLsp
  module RubyLspI18n
    GLOB_PATH = "**/config/locales/**/%s.yml"
    # This class is the entry point for the addon. It is responsible for activating and deactivating the addon
    class Addon < ::RubyLsp::Addon
      extend T::Sig

      sig { void }
      def initialize
        super
        @i18n_index = T.let(nil, T.nilable(I18nIndex))
        @enabled = T.let(true, T::Boolean)
        @language = T.let("es", String)
      end

      # Performs any activation that needs to happen once when the language server is booted)}
      sig { override.params(global_state: RubyLsp::GlobalState, message_queue: Thread::Queue).void }
      def activate(global_state, message_queue)
        settings = global_state.settings_for_addon(name) || {}
        @enabled = settings[:enabled] if settings.key?(:enabled)
        return unless @enabled

        @language = settings[:language] if settings[:language]
        @i18n_index = I18nIndex.new(language: @language)

        files_path = GLOB_PATH % @language
        files = Dir[files_path]
        files.each do |file|
          @i18n_index.sync_file(file)
        end

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
                      glob_pattern: files_path,
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
        return unless @i18n_index

        changes.each do |change|
          change = Interface::FileEvent.new(uri: change[:uri], type: change[:type])
          uri = T.let(change.uri, String)

          next unless uri.end_with?("es.yml")

          path = URI.parse(uri).path

          next if path.nil?

          path = path.gsub(Dir.pwd + "/", "")
          @i18n_index.sync_file(path)
        end
      end

      sig { override.returns(String) }
      def version
        RubyLsp::RubyLspI18n::VERSION
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
        return unless @enabled && @i18n_index

        InlayHints.new(@i18n_index, response_builder, dispatcher, document)
      end

      sig do
        override.params(
          response_builder: RubyLsp::ResponseBuilders::CollectionResponseBuilder[
            LanguageServer::Protocol::Interface::CompletionItem
          ],
          node_context: RubyLsp::NodeContext,
          dispatcher: Prism::Dispatcher,
          uri: URI::Generic,
        ).void
      end
      def create_completion_listener(response_builder, node_context, dispatcher, uri)
        return unless @enabled && @i18n_index

        Completion.new(@i18n_index, response_builder, dispatcher)
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
