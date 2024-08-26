# frozen_string_literal: true

module RubyLsp
  module RubyLspI18n
    # The database holds a data structure that maps i18n keys
    # to their values and the files they are defined in.
    class I18nDatabase
      LANGUAGE = "es"
      attr_reader :data

      ROOT_PATH = Pathname.new(".")
      TRANSLATION_PATH = ROOT_PATH.join("**/config/locales/**/*es.yml")

      def initialize
        @translation_path = TRANSLATION_PATH
        @data = Hash.new do |hash, key|
          hash[key] = []
        end
      end

      def add(key, value, file)
        @data[key] << { value: value, file: file }
      end

      def remove(key, file)
        @data[key].delete_if { |v| v[:file] == file }
      end

      def find(key)
        datum = @data.dig(key)
        datum
      end

      def update(key, value, file)
        remove(key, file)
        add(key, value, file)
      end

      def load_file(path)
        begin
          translations = YAML.load_file(path)
        rescue Psych::SyntaxError
          return
        end

        translations = translations.dig(LANGUAGE)
        return unless translations.is_a?(Hash)

        process_translations(translations, path)
      end

      def update_file(path)
        begin
          translations = YAML.load_file(path)
        rescue Psych::SyntaxError
          return
        end

        translations = translations.dig(LANGUAGE)
        return unless translations.is_a?(Hash)

        process_translations(translations, path)
      end

      def delete_file(path)
        @data.delete_if { |_, value| value.any? { |v| v[:file] == path } }
      end

      def start
        files = Dir.glob(@translation_path)
        files.each do |file|
          load_file(file)
        end
      end

      private

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
