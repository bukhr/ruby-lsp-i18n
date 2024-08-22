# frozen_string_literal: true

module RubyLsp
  module RubyLspI18n
    class InlayHints
      extend T::Sig
      include Requests::Support::Common

      def initialize(response_builder, range, hints_configuration, dispatcher)
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

        @response_builder << Interface::InlayHint.new(
          position: { line: node.location.start_line - 1, character: node.location.end_column },
          label: key.unescaped,
          padding_left: true,
          tooltip: "This is a I18n translation key in file: /home/es.yml",
        )
      end
    end
  end
end
