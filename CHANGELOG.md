## [Unreleased]
## [0.4.1] - 2025-07-21

- Updated RubyLsp to 0.25

## [0.4.0] - 2025-07-18

- Removed sorbet runtime dependency
- Fix bad use of generics because of RubyLsp sorbet runtime removal
- Updated RubyLsp to 0.25

## [0.3.0] - 2025-07-18

- Fix inlay hints patch thanks to [@enmy](https://github.com/enmy)
- Publish to rubygems

## [0.2.4] - 2025-01-13

- Update ruby lsp version to 0.23.0

## [0.2.3] - 2024-11-29

- Update ruby lsp version to 0.22.0

## [0.2.2] - 2024-11-18

- Update ruby LSP version to 0.21.3 and change runtime dependency to version constraint using the RubyLSP version constraint API to be forward compatible with new LSP versions. Now when the LSP get a breaking change the addon is disabled instead of locking the core LSP version in the editor.

## [0.2.1] - 2024-09-09

- Fix translation missing inlay hint in scoped I18n.t calls

## [0.2.0] - 2024-09-09

- Added enable/disable addon vía .vscode.settings.json file using <https://github.com/Shopify/ruby-lsp/pull/2513>

## [0.1.0] - 2024-09-03

- Added inlay hints with translation value for I18n.t("key") calls
- Added autocompletion for I18n.t("key") calls
- Added "translation-missing" for I18n.t("key") calls as inlay hint
- Added file path suggestion for I18n.t("key") missing calls
- Added tooltip with translations and file path for I18n.t("key") calls

## [0.0.0] - 2024-08-22
