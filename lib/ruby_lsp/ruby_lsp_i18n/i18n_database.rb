# frozen_string_literal: true

module RubyLsp
  module RubyLspI18n
    class I18nDatabase
      attr_reader :data

      ROOT_PATH = Pathname.new(".")
      TRANSLATION_PATH = ROOT_PATH.join("**/config/locales/**/*.yml")

      def initialize
        @data = load_translation_data
      end

      def find(key, language = "es")
        datum = @data.dig(language, key)
        value = datum[:value]
        files = datum[:files]

        return "i18n: translation missing", [] if files.none?

        [value, files]
      end

      private

      def load_translation_data
        translation_files = Dir.glob(TRANSLATION_PATH)
        all_keys = Hash.new do |hash, key|
          hash[key] = Hash.new do |h, k|
            h[k] = {
              value: nil,
              files: [],
            }
          end
        end

        translation_files.each do |file|
          next unless file.match?(%r/config\/locales(\/.*)?\/[a-z]{2}(-[a-z]{2})?\.yml$/)

          translations = YAML.load_file(file, aliases: true)
          language = File.basename(file, ".yml")
          keys = extract_keys(translations, language)
          keys.each do |key|
            full_key = "#{language}.#{key}"
            translation = translations.dig(*full_key.split("."))
            all_keys[language][key][:value] = translation
            all_keys[language][key][:files] << file
          end
        end
        all_keys
      end

      def extract_keys(translations, language, prefix = nil)
        keys = []
        translations.each do |key, value|
          full_key = prefix ? "#{prefix}.#{key}" : key
          if value.is_a?(Hash)
            keys.concat(extract_keys(value, language, full_key))
          else
            keys << full_key.sub(/^#{language}\./, "")
          end
        end
        keys
      end
    end
  end
end
