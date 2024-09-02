# RubyLspI18n

The `ruby-lsp-i18n` gem provides internationalization support for Ruby Lsp.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Features

- Inlay Hints for translations
  - Show value as inlay hint for translation keys
  - Hover with the translation value
  - Hover with the file path of the translation

- Autocompletion for translation keys
- Synchronization of yml translation files

![Ruby LSP I18n Demo](media/demo.gif)

## Development

1. Clone the repository
2. Install dependencies with `bundle install`
3. Run the tests with `bundle exec rake test`
4. Check types with `bundle exec srb tc`
5. Run the linter with `bundle exec rubocop`
6. Make a PR and wait for aproval
7. Merge the PR

To install this gem onto your local machine, run `bundle exec rake install`.

<!-- To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org). -->

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/bukhr/ruby-lsp-i18n>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/bukhr/ruby-lsp-i18n/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RubyLspI18n project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bukhr/ruby-lsp-i18n/blob/master/CODE_OF_CONDUCT.md).
