# typed: strict
# frozen_string_literal: true

module RubyLsp
  module RubyLspI18n
    class Completion
      include Requests::Support::Common

      #: (I18nIndex, ResponseBuilders::CollectionResponseBuilder, Prism::Dispatcher) -> void
      def initialize(i18n_index, response_builder, dispatcher)
        @i18n_index = i18n_index
        @response_builder = response_builder
        @dispatcher = dispatcher

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

        key_node = arguments.arguments.first
        return unless key_node.is_a?(Prism::StringNode)

        key = key_node.unescaped
        opening_location = key_node.opening_loc #: as !nil
        quote = opening_location.slice
        candidates = @i18n_index.find_prefix(key)

        candidates.each do |candidate|
          new_text = "#{quote}#{candidate}#{quote}"
          response = Interface::CompletionItem.new(
            label: new_text,
            detail: candidate,
            documentation: "candidate",
            text_edit: Interface::TextEdit.new(
              range: range_from_location(key_node.location),
              new_text: new_text,
            ),
            kind: Constant::CompletionItemKind::VALUE,
          )
          @response_builder << response
        end
      end
    end
  end
end
