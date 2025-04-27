# frozen_string_literal: true

Kernel.load('lib/nested_objects/version.rb')

Gem::Specification.new do |spec|
  spec.name = 'nested_objects'
  spec.version = NestedObjects::VERSION
  spec.authors = ['James Couball']
  spec.email = ['jcouball@yahoo.com']

  spec.summary = 'Utilities for working with PORO structures arbitrarily nested with Hashes and Arrays'

  spec.description = <<~DESCRIPTION
    Utility methods such as deep_copy, dig, bury, delete, and path? for working with
    PORO structures arbitrarily nested with Hashes and Arrays.
  DESCRIPTION

  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'
  spec.requirements = [
    'Platform: Mac, Linux, or Windows',
    'Ruby: MRI 3.1 or later, TruffleRuby 24 or later, or JRuby 9.4 or later'
  ]

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  # Project links
  spec.homepage = "https://github.com/main-branch/#{spec.name}"
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['documentation_uri'] = "https://gemdocs.org/#{spec.name}/#{spec.version}"
  spec.metadata['changelog_uri'] = "https://gemdocs.org/#{spec.name}/#{spec.version}/file.CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler-audit', '~> 0.9'
  spec.add_development_dependency 'create_github_release', '~> 2.1'
  spec.add_development_dependency 'main_branch_shared_rubocop_config', '~> 0.1'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rubocop', '~> 1.75'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'simplecov-json', '~> 0.2'
  spec.add_development_dependency 'simplecov-rspec', '~> 0.4'

  unless RUBY_PLATFORM == 'java'
    spec.add_development_dependency 'redcarpet', '~> 3.6'
    spec.add_development_dependency 'yard', '~> 0.9', '>= 0.9.28'
    spec.add_development_dependency 'yardstick', '~> 0.9'
  end
  spec.metadata['rubygems_mfa_required'] = 'true'
end
