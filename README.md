# nested_objects gem

[![Gem Version](https://badge.fury.io/rb/nested_objects.svg)](https://badge.fury.io/rb/nested_objects)
[![Build Status](https://github.com/main-branch/nested_objects/actions/workflows/continuous_integration.yml/badge.svg)](https://github.com/main-branch/nested_objects/actions/workflows/continuous_integration.yml)
[![Documentation](https://img.shields.io/badge/Documentation-Latest-green)](https://rubydoc.info/gems/nested_objects/)
[![Change Log](https://img.shields.io/badge/CHANGELOG-Latest-green)](https://rubydoc.info/gems/nested_objects/file/CHANGELOG.md)
[![Slack](https://img.shields.io/badge/slack-main--branch/track__open__instances-yellow.svg?logo=slack)](https://main-branch.slack.com/archives/C01CHR7TMM2)

The `NestedObjects` module provides module level methods to safely navigate and
manage a heirarchy of Ruby POROs nested using Hashes or Arrays. Think of these
nested data objects like what you would get after reading in a JSON file.

The key methods are:

* `NestedObjects.deep_copy(data)` - returns a deep copy of data including nested hash
  values and array elements
* `NestedObjects.dig(data, path)` - returns the value at the given path
* `NestedObjects.bury(data, path, value)` - sets a value within the data structure at
  the given path
* `NestedObjects.delete(data, path)` - deletes the Hash key or Array index at the
  given path
* `NestedObjects.path?(data, path)` - returns true if the path exists in the given
  data structure

These methods (prefixed with `nested_` to avoid method conflicts) can be mixed into
`Object` for ease of use:

```Ruby
Object.include NestedObjects::Mixin

data = { 'users' => [{ 'name' => 'John Smith'}, { 'name' => 'Jane Doe' }] }

data.nested_dig(%w[users 1 name]) #=> 'Jane Doe'
```

If the path is malformed or does not exist, a `BadPathError` will be raised.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bundle exec rake` to run tests, static analysis, and build the gem.

For experimentation, you can also run `bin/console` for an interactive (IRB) prompt that
automatically requires nested_objects.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/main-branch/nested_objects>.

### Commit message guidelines

All commit messages must follow the [Conventional Commits
standard](https://www.conventionalcommits.org/en/v1.0.0/). This helps us maintain a
clear and structured commit history, automate versioning, and generate changelogs
effectively.

To ensure compliance, this project includes:

- A git commit-msg hook that validates your commit messages before they are accepted.

  To activate the hook, you must have node installed and run `npm install`.

- A GitHub Actions workflow that will enforce the Conventional Commit standard as
  part of the continuous integration pipeline.

  Any commit message that does not conform to the Conventional Commits standard will
  cause the workflow to fail and not allow the PR to be merged.

### Pull request guidelines

All pull requests must be merged using rebase merges. This ensures that commit
messages from the feature branch are preserved in the release branch, keeping the
history clean and meaningful.
