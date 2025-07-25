# typed: strict
# frozen_string_literal: true

require "ruby_lsp/addon"
require_relative "requests/inlay_hints"
require_relative "listeners/inlay_hints"
require_relative "listeners/completion"
require_relative "i18n_index"
require_relative "../../ruby_lsp_i18n/version"

RubyLsp::Addon.depend_on_ruby_lsp!("~> 0.26.0")

module RubyLsp
  module RubyLspI18n
    GLOB_PATH = "**/config/locales/**/es.yml"
    # This class is the entry point for the addon. It is responsible for activating and deactivating the addon
    class Addon < ::RubyLsp::Addon
      #: -> void
      def initialize
        super
        @i18n_index = I18nIndex.new(language: "es") #: I18nIndex
        @enabled = true #: bool
      end

      # Performs any activation that needs to happen once when the language server is booted)}
      # @override
      #: (RubyLsp::GlobalState, Thread::Queue) -> void
      def activate(global_state, message_queue)
        settings = global_state.settings_for_addon(name) || {}
        @enabled = settings[:enabled] if settings.key?(:enabled)

        return unless @enabled

        files = Dir[GLOB_PATH]
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
      # @override
      #: -> void
      def deactivate; end

      #: (Array[Hash[Symbol, untyped]]) -> void
      def workspace_did_change_watched_files(changes)
        changes.each do |change|
          change = Interface::FileEvent.new(uri: change[:uri], type: change[:type])
          uri = change.uri #: String

          next unless uri.end_with?("es.yml")

          path = URI.parse(uri).path

          next if path.nil?

          path = path.gsub(Dir.pwd + "/", "")
          @i18n_index.sync_file(path)
        end
      end

      # @override
      #: -> String
      def version
        RubyLsp::RubyLspI18n::VERSION
      end

      # Returns the name of the addon
      # @override
      #: -> String
      def name
        "Ruby LSP I18n"
      end

      #: (ResponseBuilders::CollectionResponseBuilder, Prism::Dispatcher, (RubyDocument | ERBDocument)) -> void
      def create_inlay_hints_listener(response_builder, dispatcher, document)
        return unless @enabled

        InlayHints.new(@i18n_index, response_builder, dispatcher, document)
      end

      # @override
      #: (ResponseBuilders::CollectionResponseBuilder, RubyLsp::NodeContext, Prism::Dispatcher, URI::Generic) -> void
      def create_completion_listener(response_builder, node_context, dispatcher, uri)
        return unless @enabled

        Completion.new(@i18n_index, response_builder, dispatcher)
      end
    end
  end
end

# Patch the InlayHints request to support addons
module RubyLsp
  class Addon
    #: (ResponseBuilders::CollectionResponseBuilder, Prism::Dispatcher, (RubyDocument | ERBDocument)) -> void
    def create_inlay_hints_listener(response_builder, dispatcher, document)
    end
  end
end
