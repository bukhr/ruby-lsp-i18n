# frozen_string_literal: true

module RubyLsp
  module RubyLspI18n
    class I18nDatabase
      attr_reader :data

      ROOT_PATH = Pathname.new(".")
      TRANSLATION_PATH = ROOT_PATH.join("**/config/locales/**/*es.yml")

      def initialize
        @data = Hash.new do |hash, key|
          hash[key] = {
            value: 0,
            files: [],
          }
        end

        load_translation_data
      end

      def find(key)
        datum = @data.dig(key)
        value = datum[:value]
        files = datum[:files]

        return "i18n: translation missing", [] if files.none?

        [value, files]
      end

      def add_keys(file)
        file = parse_file_uri(file)
        translations = get_yaml_translations(file)

        return if translations.nil?

        keys = extract_keys(translations)
        keys.each do |key|
          translation = translations.dig(*key.split("."))
          @data[key][:value] = translation
          @data[key][:files] << file
        end
      end

      def remove_keys(file)
        file = parse_file_uri(file)
        translations = get_yaml_translations(file)
        keys = extract_keys(translations)
        keys.each do |key|
          @data.delete(key)
        end
      end

      def update_keys(file)
        file = parse_file_uri(file)
        File.open("log.txt", "a") do |f|
          f.puts "File updated: #{file}"
        end
        remove_keys(file)
        add_keys(file)
      end

      def parse_file_uri(file)
        file.gsub("file://", "")
      end

      private

      def get_yaml_translations(file)
        begin
          translations = YAML.load_file(file, aliases: true)
        rescue Psych::SyntaxError => e
          return {}
        end
        language = "es"
        translations = translations.dig(language)

        if translations.nil?
          return {}
        end

        translations
      end

      def load_translation_data
        translation_files = Dir.glob(TRANSLATION_PATH)
        translation_files.each do |file|
          add_keys(file)
        end
      end

      def extract_keys(translations, prefix = nil)
        keys = []
        translations.each do |key, value|
          next unless key.is_a?(String)

          full_key = prefix ? "#{prefix}.#{key}" : key
          if value.is_a?(Hash)
            keys.concat(extract_keys(value, full_key))
          else
            keys << full_key
          end
        end
        keys
      end
    end
  end
end
