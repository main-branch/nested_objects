# frozen_string_literal: true

require_relative 'nested_objects/mixin'
require_relative 'nested_objects/version'

# Utilities for working with POROs arbitrarily nested with Hashes and Arrays
# @api public
module NestedObjects
  # Error raised when a path is invalid or does not exist in the data
  class BadPathError < StandardError; end

  class << self
    # Creates a deep copy of data using Marshal
    #
    # @example
    #   data = { 'a' => { 'b' => [1, 2, 3] } }
    #   NestedObjects.deep_copy(data) #=> { 'a' => { 'b' => [1, 2, 3] } }
    #
    # @param data [Object] The object to be deeply copied
    # @return [Object] A new object that is a deep copy of the input `obj`
    # @raise [TypeError] if the object cannot be marshaled (see Marshal documentation)
    def deep_copy(data)
      Marshal.load(Marshal.dump(data))
    end

    # Retrieves the value at the specified path in the given data
    #
    # @example
    #   data = { 'a' => { 'b' => [1, 2, 3] } }
    #   NestedObjects.dig(data, ['a', 'b', '0']) #=> 1
    #
    # @param data [Hash, Array, Object] The data containing the value to retrieve
    # @param path [Array<String>] An array of keys/indices representing the path to the desired value
    # @return [Object] the value at the specified path
    # @raise [BadPathError] if the path is invalid or does not exist
    def dig(data, path)
      return data if path.empty?

      raise BadPathError unless data.is_a?(Hash) || data.is_a?(Array)

      if data.is_a?(Hash)
        dig_into_hash(data, path)
      else
        dig_into_array(data, path)
      end
    end

    # Sets a value within a nested data structure
    #
    # Creates intermediate Hashes along the path if they do not exist.
    # Does NOT create intermediate Arrays (creates a Hash instead).
    #
    # @example
    #   data = { 'a' => { 'b' => [1, 2, 3] } }
    #   NestedObjects.bury(data, ['a', 'b', '0'], 42) #=> { 'a' => { 'b' => [42, 2, 3] } }
    #
    # @example will overwrite existing values
    #   data = { 'a' => { 'b' => [1, 2, 3] } }
    #   NestedObjects.bury(data, ['a'], 42) #=> { 'a' => 42 }
    #
    # @example will create intermediate Hashes
    #   data = {}
    #   NestedObjects.bury(data, ['a', 'b'], 42) #=> { 'a' => { 'b' => 42 } })
    #
    # @example will NOT create intermediate Arrays (creates a Hash instead)
    #   data = {}
    #   NestedObjects.bury(data, ['a', '0'], 42) #=> { 'a' => { '0' => [42, 2, 3] } }
    #
    # @param data [Hash, Array, Object] The structure to modify
    # @param path [Array<String>] An array of keys/indices representing the path to the item to set
    # @param value [Object] The value to set at the specified path
    # @return [Object] The modified data structure
    # @raise [BadPathError] if the path is invalid or the item does not exist
    #
    def bury(data, path, value)
      raise BadPathError if path.empty? || !(data.is_a?(Hash) || data.is_a?(Array))

      key, found = next_key(data, path)

      if path.length == 1
        data[key] = value
      else
        data[key] = {} unless found
        bury(data[key], path[1..], value)
      end

      data
    end

    # Delete a key or element from nested data identified by path
    #
    # @example
    #   data = { 'a' => { 'b' => [1, 2, 3] } }
    #   NestedObjects.delete(data, ['a', 'b', '0']) #=> 1
    #   data #=> { 'a' => { 'b' => [2, 3] } }
    #
    # @param data [Hash, Array, Object] The structure to modify
    # @param path [Array<String>] An array of keys/indices representing the path to the item to delete
    # @return [Object] The value of the element that was deleted
    # @raise [BadPathError] if the path is invalid or the item does not exist
    #
    def delete(data, path)
      raise BadPathError if path.empty? || !(data.is_a?(Hash) || data.is_a?(Array))

      key, found = next_key(data, path)

      raise BadPathError unless found

      if path.length == 1
        delete_key(data, key)
      else
        delete(data[key], path[1..])
      end
    end

    # Check if the path is valid for the given data structure
    #
    # @example
    #   data = { 'a' => { 'b' => [1, 2, 3] } }
    #   NestedObjects.path?(data, ['a', 'b', '0']) #=> true
    #   NestedObjects.path?(data, ['d']) #=> false
    #
    # @param data [Hash, Array, Object] The structure to check
    # @param path [Array<String>] An array of keys/indices representing the path to check
    # @return [Boolean] `true` if the path is valid, `false` otherwise
    # @raise [BadPathError] if path tries to traverse an Array with a non-integer key
    #
    def path?(data, path)
      return true if path.empty?

      return false unless data.is_a?(Hash) || data.is_a?(Array)

      key, found = next_key(data, path)

      return false unless found

      path?(data[key], path[1..])
    end

    private

    # Traverse through a Hash via the nest path component
    # @return the value at the end of the path
    # @raise [BadPathError] if the path is invalid or does not exist
    # @api private
    def dig_into_hash(data, path)
      key = path.first
      raise BadPathError unless data.key?(key)

      dig(data[key], path[1..])
    end

    # Traverse through an Array via the nest path component
    # @return the value at the end of the path
    # @raise [BadPathError] if the path is invalid or does not exist
    # @api private
    def dig_into_array(data, path)
      index = key_to_index(path.first)
      raise BadPathError unless !index.nil? && index >= 0 && index < data.length

      dig(data[index], path[1..])
    end

    # Delete a Hash key or an Array element from data
    # @return the value of the element that was deleted
    # @api private
    def delete_key(data, key)
      if data.is_a?(Hash)
        data.delete(key)
      else
        data.delete_at(key)
      end
    end

    # The next key in the path and whether it exists in the root of the data structure
    #
    # The next key is a string for Hashes and an integer for Arrays
    #
    # @example
    #   next_key({ 'a' => 1 }, ['a']) #=> ['a', true]
    #   next_key({ 'a' => 1 }, ['b']) #=> ['b', false]
    # @param data [Hash, Array, Object] The data structure to check
    # @param path [Array<String>] An array of keys/indices representing the path being traversed
    # @return [Array<[String, Integer], Boolean>] The next key and whether it exists
    # @api private
    def next_key(data, path)
      if data.is_a?(Hash)
        key = path.first
        [key, data.key?(key)]
      else
        index = key_to_index(path.first)
        [index, index >= 0 && index < data.length]
      end
    end

    # Convert a String key to an Integer array index
    # @param key [String] The key to convert to an index
    # @return [Integer] the index of the key in the array
    # @raise [BadPathError] if the key is not a String representation of an Integer
    # @api private
    def key_to_index(key)
      Integer(key)
    rescue ArgumentError
      raise BadPathError
    end
  end
end
