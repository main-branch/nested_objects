# frozen_string_literal: true

require 'English'
require 'rspec'
require 'tempfile'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# SimpleCov configuration
#
require 'simplecov'
require 'simplecov-json'
require 'simplecov-rspec'

def ci_build? = ENV.fetch('GITHUB_ACTIONS', 'false') == 'true'

if ci_build?
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter
  ]
end

# Platform
def windows? = Gem.win_platform?
def mac? = RUBY_PLATFORM.include?('darwin')
def linux? = RUBY_PLATFORM.include?('linux')

# Engine
def truffleruby? = RUBY_ENGINE == 'truffleruby'
def jruby? = RUBY_ENGINE == 'jruby'
def mri? = RUBY_ENGINE == 'ruby'

def pbcopy(arg)
  raise 'pbcopy is only available on macOS' unless mac?

  IO.popen('pbcopy', 'w') { |io| io.puts arg }
end

SimpleCov::RSpec.start(list_uncovered_lines: ci_build?)

require 'nested_objects'
