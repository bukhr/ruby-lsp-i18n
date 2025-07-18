# typed: strict
# frozen_string_literal: true

module RubyLsp
  module RubyLspI18n
    class InlayHints
      include Requests::Support::Common

      #: (I18nIndex, ResponseBuilders::CollectionResponseBuilder, Prism::Dispatcher, (RubyDocument | ERBDocument)) -> void
      def initialize(i18n_index, response_builder, dispatcher, document)
        absolute_path = document.uri.path
        @absolute_path = absolute_path #: String
        @path = Pathname(absolute_path).relative_path_from(Dir.pwd) #: Pathname
        @i18n_index = i18n_index
        @response_builder = response_builder

        dispatcher.register(
          self,
          :on_call_node_enter,
        )
      end

      #: (Prism::CallNode) -> void
      def on_call_node_enter(node)
        return unless node.name == :t

        receiver = node.receiver
        return unless receiver.is_a?(Prism::ConstantReadNode)

        return unless receiver.name == :I18n

        arguments = node.arguments
        return unless arguments
        return if arguments.arguments.empty?

        return if i18n_arguments_has_scope_argument(arguments)

        key_node = arguments.arguments.first
        return unless key_node.is_a?(Prism::StringNode)

        key = key_node.unescaped

        matches = @i18n_index.find(key)

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

      #: (String path) -> String
      def create_file_uri(path)
        base_uri = "file://#{Dir.pwd}/"
        URI.join(base_uri, path).to_s
      end

      #: (Prism::ArgumentsNode arguments) -> bool
      def i18n_arguments_has_scope_argument(arguments)
        arguments = arguments.arguments
        return false if arguments.size <= 1

        # Check if the key is scoped, and if it is, ignore it
        keyword_arguments = arguments[1]
        if keyword_arguments.is_a?(Prism::KeywordHashNode)
          keyword_argument_nodes = keyword_arguments.elements.grep(Prism::AssocNode)
          keyword_argument_nodes.each do |arg|
            key = arg.key
            next unless key.is_a?(Prism::SymbolNode)

            if key.value == "scope"
              return true
            end
          end
        end
        false
      end
    end
  end
end
