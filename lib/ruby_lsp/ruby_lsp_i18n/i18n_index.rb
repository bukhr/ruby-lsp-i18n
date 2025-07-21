# typed: strict
# frozen_string_literal: true

require_relative "prefix_tree"
module RubyLsp
  module RubyLspI18n
    # The index holds a data structure that maps i18n keys
    # to their values and the files they are defined in.

    class Entry
      #: String
      attr_reader :value

      #: String
      attr_reader :file

      #: (String, String) -> void
      def initialize(value, file)
        @value = value
        @file = file
      end
    end

    class I18nIndex
      #: (language: String) -> void
      def initialize(language:)
        @language = language
        @data = {} #: Hash[String, Array[Entry]]

        @file_keys = Hash.new do |hash, key|
          hash[key] = []
        end #: Hash[String, Array[String]]

        @keys_tree = RubyLsp::RubyLspI18n::PrefixTree.new #: RubyLsp::RubyLspI18n::PrefixTree[String]
      end

      #: (String key, String value, String file) -> void
      def add(key, value, file)
        entry = Entry.new(value, file)
        @data[key] ||= []
        data_key = @data[key] #: as !nil
        data_key << entry
        data_file = @file_keys[file] #: as !nil
        data_file << key
        @keys_tree.insert(key, key)
      end

      #: (String key, String file) -> void
      def remove(key, file)
        return unless @data[key]

        data_key = @data[key] #: as !nil
        data_key.delete_if { |v| v.file == file }
        data_file = @file_keys[file] #: as !nil
        data_file.delete(key)
        @keys_tree.delete(key)
      end

      #: (String key) -> Array[RubyLsp::RubyLspI18n::Entry]
      def find(key)
        datum = @data.dig(key)
        datum.nil? ? [] : datum
      end

      #: (String prefix) -> Array[String]
      def find_prefix(prefix)
        @keys_tree.search(prefix)
      end

      #: (String key, String value, String file) -> void
      def update(key, value, file)
        remove(key, file)
        add(key, value, file)
      end

      #: (String path) -> void
      def sync_file(path)
        # Clean entries from the file
        current_keys = get_keys_from_file(path)
        current_keys.each do |key|
          remove(key, path)
        end

        return unless File.exist?(path)

        # Load translations only if the current yaml is valid
        begin
          translations = YAML.load_file(path, aliases: true, permitted_classes: [Symbol, Date])
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

      #: (String file) -> Array[String]
      def get_keys_from_file(file)
        @file_keys[file] #: as !nil
      end

      #: (Hash[String, untyped] translations, String file, ?String? prefix) -> void
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
