# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `bump` gem.
# Please instead update this file by running `bin/tapioca gem bump`.


# source://bump/lib/bump.rb#3
module Bump
  class << self
    # Returns the value of attribute changelog.
    #
    # source://bump/lib/bump.rb#13
    def changelog; end

    # Sets the attribute changelog
    #
    # @param value the value to set the attribute changelog to.
    #
    # source://bump/lib/bump.rb#13
    def changelog=(_arg0); end

    # Returns the value of attribute replace_in_default.
    #
    # source://bump/lib/bump.rb#13
    def replace_in_default; end

    # Sets the attribute replace_in_default
    #
    # @param value the value to set the attribute replace_in_default to.
    #
    # source://bump/lib/bump.rb#13
    def replace_in_default=(_arg0); end

    # Returns the value of attribute tag_by_default.
    #
    # source://bump/lib/bump.rb#13
    def tag_by_default; end

    # Sets the attribute tag_by_default
    #
    # @param value the value to set the attribute tag_by_default to.
    #
    # source://bump/lib/bump.rb#13
    def tag_by_default=(_arg0); end
  end
end

# source://bump/lib/bump.rb#16
class Bump::Bump
  class << self
    # source://bump/lib/bump.rb#71
    def current; end

    # source://bump/lib/bump.rb#23
    def defaults; end

    # source://bump/lib/bump.rb#100
    def file; end

    # source://bump/lib/bump.rb#75
    def next_version(increment, current = T.unsafe(nil)); end

    # source://bump/lib/bump.rb#104
    def parse_cli_options!(options); end

    # source://bump/lib/bump.rb#34
    def run(bump, options = T.unsafe(nil)); end

    private

    # source://bump/lib/bump.rb#123
    def bump(file, current, next_version, options); end

    # source://bump/lib/bump.rb#188
    def bump_changelog(file, current); end

    # source://bump/lib/bump.rb#177
    def bump_part(increment, options); end

    # source://bump/lib/bump.rb#183
    def bump_set(next_version, options); end

    # source://bump/lib/bump.rb#165
    def bundler_with_clean_env(&block); end

    # source://bump/lib/bump.rb#216
    def commit(version, options); end

    # source://bump/lib/bump.rb#211
    def commit_message(version, options); end

    # @raise [UnfoundVersionError]
    #
    # source://bump/lib/bump.rb#233
    def current_info; end

    # source://bump/lib/bump.rb#290
    def extract_version_from_file(file); end

    # source://bump/lib/bump.rb#296
    def find_version_file(pattern); end

    # source://bump/lib/bump.rb#222
    def git_add(file); end

    # source://bump/lib/bump.rb#160
    def open_changelog(log); end

    # source://bump/lib/bump.rb#113
    def parse_cli_options_value(value); end

    # source://bump/lib/bump.rb#226
    def replace(file, old, new); end

    # @return [Boolean]
    #
    # source://bump/lib/bump.rb#306
    def under_version_control?(file); end

    # source://bump/lib/bump.rb#283
    def version_from_chef; end

    # source://bump/lib/bump.rb#247
    def version_from_gemspec; end

    # source://bump/lib/bump.rb#275
    def version_from_lib_rb; end

    # source://bump/lib/bump.rb#269
    def version_from_version; end

    # source://bump/lib/bump.rb#260
    def version_from_version_rb; end
  end
end

# source://bump/lib/bump.rb#17
Bump::Bump::BUMPS = T.let(T.unsafe(nil), Array)

# source://bump/lib/bump.rb#19
Bump::Bump::OPTIONS = T.let(T.unsafe(nil), Array)

# source://bump/lib/bump.rb#18
Bump::Bump::PRERELEASE = T.let(T.unsafe(nil), Array)

# source://bump/lib/bump.rb#20
Bump::Bump::VERSION_REGEX = T.let(T.unsafe(nil), Regexp)

# source://bump/lib/bump.rb#4
class Bump::InvalidIncrementError < ::StandardError; end

# source://bump/lib/bump.rb#5
class Bump::InvalidOptionError < ::StandardError; end

# source://bump/lib/bump.rb#6
class Bump::InvalidVersionError < ::StandardError; end

# source://bump/lib/bump.rb#10
class Bump::RakeArgumentsDeprecatedError < ::StandardError; end

# source://bump/lib/bump.rb#8
class Bump::TooManyVersionFilesError < ::StandardError; end

# source://bump/lib/bump.rb#7
class Bump::UnfoundVersionError < ::StandardError; end

# source://bump/lib/bump.rb#9
class Bump::UnfoundVersionFileError < ::StandardError; end
