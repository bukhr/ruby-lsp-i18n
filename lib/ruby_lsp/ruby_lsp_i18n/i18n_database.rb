# typed: strict
# frozen_string_literal: true

require "trie"
module RubyLsp
  module RubyLspI18n
    # The database holds a data structure that maps i18n keys
    # to their values and the files they are defined in.

    class Entry
      extend T::Sig

      sig { returns(String) }
      attr_reader :value

      sig { returns(String) }
      attr_reader :file

      sig { params(value: String, file: String).void }
      def initialize(value, file)
        @value = value
        @file = file
      end
    end

    class I18nDatabase
      extend T::Sig

      sig { returns(T::Hash[String, T::Array[Entry]]) }
      attr_reader :data

      sig { params(language: String).void }
      def initialize(language:)
        @language = language
        @data = T.let({}, T::Hash[String, T::Array[Entry]])

        @file_keys = T.let(
          Hash.new do |hash, key|
            hash[key] = []
          end,
          T::Hash[String, T::Array[String]],
        )

        @keys_tree = T.let(Trie.new, Trie)
      end

      sig { params(key: String, value: String, file: String).void }
      def add(key, value, file)
        entry = Entry.new(value, file)
        @data[key] ||= []
        T.must(@data[key]) << entry
        T.must(@file_keys[file]) << key
        @keys_tree.add(key)
      end

      sig { params(key: String, file: String).void }
      def remove(key, file)
        return unless @data[key]

        T.must(@data[key]).delete_if { |v| v.file == file }
        T.must(@file_keys[file]).delete(key)
        @keys_tree.delete(key)
      end

      sig { params(key: String).returns(T.nilable(T::Array[RubyLsp::RubyLspI18n::Entry])) }
      def find(key)
        datum = @data.dig(key)
        datum
      end

      sig { params(prefix: String).returns(T::Array[String]) }
      def find_prefix(prefix)
        @keys_tree.children(prefix)
      end

      sig { params(key: String, value: String, file: String).void }
      def update(key, value, file)
        remove(key, file)
        add(key, value, file)
      end

      sig { params(path: String).void }
      def sync_file(path)
        # Clean entries from the file
        current_keys = get_keys_from_file(path)
        current_keys.each do |key|
          remove(key, path)
        end

        return unless File.exist?(path)

        # Load translations only if the current yaml is valid
        begin
          translations = YAML.load_file(path, aliases: true)
        rescue Psych::SyntaxError
          return
        end

        # If there is no translations, do nothing
        return unless translations.is_a?(Hash)

        # If the translations are empty, do nothing
        return if translations.dig(@language).nil?

        # Add entries again
        translations = translations.dig(@language)
        return unless translations.is_a?(Hash) # Check format of the translations

        process_translations(translations, path)
      end

      private

      sig { params(file: String).returns(T::Array[String]) }
      def get_keys_from_file(file)
        T.must(@file_keys[file])
      end

      sig { params(translations: T::Hash[String, T.untyped], file: String, prefix: T.nilable(String)).void }
      def process_translations(translations, file, prefix = nil)
        translations.each do |key, value|
          full_key = prefix ? "#{prefix}.#{key}" : key
          full_key = full_key.to_s
          if value.is_a?(Hash)
            process_translations(value, file, full_key)
          else
            update(full_key, value, file)
          end
        end
      end
    end
  end
end
