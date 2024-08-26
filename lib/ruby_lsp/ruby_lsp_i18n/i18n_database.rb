# frozen_string_literal: true

module RubyLsp
  module RubyLspI18n
    # The database holds a data structure that maps i18n keys
    # to their values and the files they are defined in.
    class I18nDatabase
      attr_reader :data

      def initialize(language:)
        @language = language
        @data = Hash.new do |hash, key|
          hash[key] = []
        end

        @file_keys = Hash.new do |hash, key|
          hash[key] = []
        end
      end

      def add(key, value, file)
        @data[key] << { value: value, file: file }
        @file_keys[file] << key
      end

      def remove(key, file)
        @data[key].delete_if { |v| v[:file] == file }
        @file_keys[file].delete(key)
      end

      def find(key)
        datum = @data.dig(key)
        datum
      end

      def update(key, value, file)
        remove(key, file)
        add(key, value, file)
      end

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

      def start(glob = TRANSLATION_PATH)
        files = Dir.glob(glob || @translation_path)
        files.each do |file|
          sync_file(file)
        end
      end

      private

      def get_keys_from_file(file)
        @file_keys[file]
      end

      def process_translations(translations, file, prefix = nil)
        translations.each do |key, value|
          full_key = prefix ? "#{prefix}.#{key}" : key
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
