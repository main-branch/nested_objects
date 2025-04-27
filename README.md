# nested_objects gem

[![Gem Version](https://badge.fury.io/rb/nested_objects.svg)](https://badge.fury.io/rb/nested_objects)
[![Build Status](https://github.com/main-branch/nested_objects/actions/workflows/continuous_integration.yml/badge.svg)](https://github.com/main-branch/nested_objects/actions/workflows/continuous_integration.yml)
[![Documentation](https://img.shields.io/badge/Documentation-Latest-green)](https://gemdocs.org/gems/nested_objects)
[![Change Log](https://img.shields.io/badge/CHANGELOG-Latest-green)](https://rubydoc.info/gems/nested_objects/file/CHANGELOG.md)
[![Slack](https://img.shields.io/badge/slack-main--branch/track__open__instances-yellow.svg?logo=slack)](https://main-branch.slack.com/archives/C01CHR7TMM2)

The `NestedObjects` module provides module methods to safely navigate and
manage a heirarchy of Ruby POROs nested using Hashes or Arrays. Think of these
nested data objects like what you would get after reading in a JSON file.

## Usage

### Module Methods

These methods are exposted on the `NestedObjects` module. The key methods are:
`deep_copy`, `dig`, `bury`, `delete`, and `path?`.

Here is an example of using the `dig` method:

```Ruby
require 'nested_objects'

data = { 'people' => [{ 'name' => 'John'}, { 'name' => 'Jane' }] }
path = 'people/0/name'.split('/')
NestedObjects.dig(data, path) #=> 'John'
```

See documentation and examples of the full API in
[the gem's YARD documentation](https://gemdocs.org/gems/nested_objects/).

### Object Mixin

As a convenience, these methods can be mixed into other classes by including the
`NestedObjects::Mixin` module.

In order to reduce the possibility of method name conflicts, all methods are prefixed
with `nested_`.

```Ruby
require 'nested_objects'

Object.include NestedObjects::Mixin

data = { 'people' => [{ 'name' => 'John'}, { 'name' => 'Jane' }] }
path = 'people/0/name'.split('/')
data.nested_dig(path) #=> 'John'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bundle exec rake` to run tests, static analysis, and build the gem.

For experimentation, you can also run `bin/console` for an interactive (IRB) prompt
that automatically requires nested_objects.

## Contributing

See [the contributing guildlines](CONTRIBUTING.md) for guidance on how to contriute
to this project.
