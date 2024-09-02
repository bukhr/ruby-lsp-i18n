# typed: strict
# frozen_string_literal: true

module RubyLsp
  module RubyLspI18n
    class InlayHints
      extend T::Sig
      include Requests::Support::Common

      sig do
        params(
          i18n_database: I18nDatabase,
          response_builder: ResponseBuilders::CollectionResponseBuilder[Interface::InlayHint],
          dispatcher: Prism::Dispatcher,
          document: T.any(RubyDocument, ERBDocument),
        ).void
      end
      def initialize(i18n_database, response_builder, dispatcher, document)
        absolute_path = T.must(document.uri.path)
        @absolute_path = T.let(absolute_path, String)
        @path = T.let(Pathname(absolute_path).relative_path_from(Dir.pwd), Pathname)
        @i18n_database = i18n_database
        @response_builder = response_builder

        dispatcher.register(
          self,
          :on_call_node_enter,
        )
      end

      sig { params(node: Prism::CallNode).void }
      def on_call_node_enter(node)
        return unless node.name == :t

        receiver = node.receiver
        return unless receiver.is_a?(Prism::ConstantReadNode)

        return unless receiver.name == :I18n

        arguments = node.arguments
        return unless arguments
        return unless arguments.arguments.size == 1

        key_node = arguments.arguments.first
        return unless key_node.is_a?(Prism::StringNode)

        key = key_node.unescaped

        matches = @i18n_database.find(key)
        matches ||= []

        tooltip_content = <<~MARKDOWN
          **Translations (es)**
          #{matches.map { |match| "- [#{match.file}](#{create_file_uri(match.file)}): #{match.value}" }.join("\n")}
        MARKDOWN

        suggested_path = @path.to_s.gsub("app", "config/locales").gsub(@path.basename.to_s, "es.yml")
        suggested_path_link = create_file_uri(suggested_path)
        if matches.empty?
          tooltip_content += <<~MARKDOWN
            ⚠️ Translation missing\n
            suggested file: [#{suggested_path}](#{suggested_path_link})
          MARKDOWN
        end

        if matches.size > 1
          tooltip_content += <<~MARKDOWN
            \n ⚠️ There are more than one translation for this key
          MARKDOWN
        end

        tooltip = Interface::MarkupContent.new(
          kind: "markdown",
          value: tooltip_content,
        )

        value = matches.first&.value || "⚠️ Translation missing"

        @response_builder << Interface::InlayHint.new(
          position: { line: node.location.start_line - 1, character: node.location.end_column },
          label: value,
          padding_left: true,
          tooltip: tooltip,
        )
      end

      private

      sig { params(path: String).returns(String) }
      def create_file_uri(path)
        base_uri = "file://#{Dir.pwd}/"
        URI.join(base_uri, path).to_s
      end
    end
  end
end
