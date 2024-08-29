# frozen_string_literal: true

module RubyLsp
  module RubyLspI18n
    class InlayHints
      extend T::Sig
      include Requests::Support::Common

      def initialize(i18n_database, response_builder, range, hints_configuration, dispatcher, document) # rubocop:disable Metrics/ParameterLists
        @absolute_path = URI.parse(document.uri).path
        @path = Pathname(URI.parse(document.uri).path).relative_path_from(Dir.pwd)
        @i18n_database = i18n_database
        @response_builder = response_builder
        @range = range
        @hints_configuration = hints_configuration

        dispatcher.register(
          self,
          :on_call_node_enter,
        )
      end

      def load_all_translation_keys
      end

      def on_call_node_enter(node)
        return unless node.name == :t

        return unless node.receiver.is_a?(Prism::ConstantReadNode) && node.receiver.name == :I18n

        return unless node.receiver.name == :I18n

        return unless node.arguments.arguments.size == 1

        key = node.arguments.arguments.first

        return unless key.is_a?(Prism::StringNode)

        key = key.unescaped

        matches = @i18n_database.find(key)

        tooltip_content = <<~MARKDOWN
          **Translations (es)**
          #{matches.map { |match| "- [#{match[:file]}](#{create_file_uri(match[:file])}): #{match[:value]}" }.join("\n")}
        MARKDOWN

        suggested_path = @path.to_s.gsub("app", "config/locales").gsub(@path.basename.to_s, "es.yml")
        suggested_path_link = @absolute_path.to_s.gsub("app", "config/locales").gsub(@path.basename.to_s, "es.yml")
        if matches.empty?
          tooltip_content += <<~MARKDOWN
            ⚠️ Translation missing\n
            suggested file: [#{suggested_path}](#{suggested_path_link})
          MARKDOWN
        end

        if matches.size > 1
          tooltip_content += <<~MARKDOWN
            \n⚠️ There are more than one translation for this key
          MARKDOWN
        end

        tooltip = Interface::MarkupContent.new(
          kind: "markdown",
          value: tooltip_content,
        )

        value = matches.first&.dig(:value) || "⚠️ Translation missing"

        @response_builder << Interface::InlayHint.new(
          position: { line: node.location.start_line - 1, character: node.location.end_column },
          label: value,
          padding_left: true,
          tooltip: tooltip,
        )
      end

      private

      # TO DO: Test in Windows and Mac OS
      def create_file_uri(path)
        "#{Dir.pwd}/#{path}"
      end
    end
  end
end
