# frozen_string_literal: true

module NestedObjects
  # Include this module to add methods for working with nested data structures
  #
  # Usually included into the Object class.
  #
  # @example
  #   require 'nested_objects/mixin'
  #   Object.include(NestedObjects::Mixin)
  #   data = { 'a' => { 'b' => [1, 2, 3] } }
  #   data.nested_dig(['a', 'b', '0']) #=> 1
  #
  # @api public
  module Mixin
    # (see NestedObjects.path?)
    def nested_path?(path) = NestedObjects.path?(self, path)

    # (see NestedObjects.dig)
    def nested_dig(path) = NestedObjects.dig(self, path)

    # (see NestedObjects.bury)
    def nested_bury(path, value) = NestedObjects.bury(self, path, value)

    # (see NestedObjects.delete)
    def nested_delete(path) = NestedObjects.delete(self, path)

    # (see NestedObjects.deep_copy)
    def nested_deep_copy = NestedObjects.deep_copy(self)
  end
end
