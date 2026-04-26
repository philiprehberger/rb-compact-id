# frozen_string_literal: true

require 'securerandom'
require_relative 'compact_id/version'

module Philiprehberger
  module CompactId
    class Error < StandardError; end

    BASE58_ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
    BASE62_ALPHABET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

    # Encode a UUID as a Base58 string
    #
    # @param uuid [String] UUID with dashes (e.g. "550e8400-e29b-41d4-a716-446655440000")
    # @return [String] Base58-encoded string
    # @raise [Error] if the UUID format is invalid
    def self.to_base58(uuid)
      validate_uuid!(uuid)
      encode(uuid_to_int(uuid), BASE58_ALPHABET, 22)
    end

    # Encode a UUID as a Base62 string
    #
    # @param uuid [String] UUID with dashes
    # @return [String] Base62-encoded string
    # @raise [Error] if the UUID format is invalid
    def self.to_base62(uuid)
      validate_uuid!(uuid)
      encode(uuid_to_int(uuid), BASE62_ALPHABET, 22)
    end

    # Decode a Base58 string back to a UUID
    #
    # @param str [String] Base58-encoded string
    # @return [String] UUID with dashes
    # @raise [Error] if the string contains invalid characters
    def self.from_base58(str)
      int_to_uuid(decode_str(str, BASE58_ALPHABET))
    end

    # Decode a Base62 string back to a UUID
    #
    # @param str [String] Base62-encoded string
    # @return [String] UUID with dashes
    # @raise [Error] if the string contains invalid characters
    def self.from_base62(str)
      int_to_uuid(decode_str(str, BASE62_ALPHABET))
    end

    # Generate a new UUID and encode it
    #
    # @param format [Symbol] :base58 or :base62
    # @return [String] encoded UUID
    # @raise [Error] if format is invalid
    def self.generate(format = :base58)
      uuid = SecureRandom.uuid

      case format
      when :base58 then to_base58(uuid)
      when :base62 then to_base62(uuid)
      else raise Error, "Unknown format: #{format}. Use :base58 or :base62"
      end
    end

    # Generate multiple compact IDs at once
    #
    # @param count [Integer] number of IDs to generate
    # @param format [Symbol] :base58 or :base62
    # @return [Array<String>] array of encoded UUIDs
    # @raise [Error] if format is invalid or count is not a positive integer
    def self.batch_generate(count, format: :base58)
      raise Error, 'Count must be a positive integer' unless count.is_a?(Integer) && count.positive?

      Array.new(count) { generate(format) }
    end

    # Generate a time-sortable ID by combining a millisecond timestamp with random bytes
    #
    # IDs generated later will always sort lexicographically after earlier ones.
    # The ID is composed of the current time in milliseconds (high bits) and 64 bits
    # of randomness (low bits), encoded in the specified format.
    #
    # @param format [Symbol] :base58 or :base62
    # @return [String] time-sortable encoded ID
    # @raise [Error] if format is unsupported
    def self.sortable_id(format: :base62)
      ms = (Time.now.to_f * 1000).to_i
      random = SecureRandom.random_number(2**64)
      combined = (ms << 64) | random

      case format
      when :base58 then encode(combined, BASE58_ALPHABET, 0)
      when :base62 then encode(combined, BASE62_ALPHABET, 0)
      else raise Error, "unsupported format: #{format}"
      end
    end

    # Bulk encode an array of UUIDs to Base58
    #
    # @param uuids [Array<String>] array of UUIDs with dashes
    # @return [Array<String>] array of Base58-encoded strings
    # @raise [Error] if any UUID format is invalid
    def self.batch_to_base58(uuids)
      raise Error, 'Expected an Array of UUIDs' unless uuids.is_a?(Array)

      uuids.map { |uuid| to_base58(uuid) }
    end

    # Bulk encode an array of UUIDs to Base62
    #
    # @param uuids [Array<String>] array of UUIDs with dashes
    # @return [Array<String>] array of Base62-encoded strings
    # @raise [Error] if any UUID format is invalid
    def self.batch_to_base62(uuids)
      raise Error, 'Expected an Array of UUIDs' unless uuids.is_a?(Array)

      uuids.map { |uuid| to_base62(uuid) }
    end

    # Convert a Base58 string directly to Base62
    #
    # @param str [String] Base58-encoded string
    # @return [String] Base62-encoded string
    # @raise [Error] if the string contains invalid characters
    def self.base58_to_base62(str)
      num = decode_str(str, BASE58_ALPHABET)
      encode(num, BASE62_ALPHABET, 22)
    end

    # Convert a Base62 string directly to Base58
    #
    # @param str [String] Base62-encoded string
    # @return [String] Base58-encoded string
    # @raise [Error] if the string contains invalid characters
    def self.base62_to_base58(str)
      num = decode_str(str, BASE62_ALPHABET)
      encode(num, BASE58_ALPHABET, 22)
    end

    # Detect the format of an encoded string
    #
    # @param str [String] encoded string to check
    # @return [Symbol] :base58, :base62, or :unknown
    def self.format?(str)
      return :unknown unless str.is_a?(String) && !str.empty?

      # Base58 is a strict subset of Base62, so check Base58 first.
      # A string is only :base62 if it contains characters outside the Base58 alphabet.
      if valid_base58?(str)
        :base58
      elsif valid_base62?(str)
        :base62
      else
        :unknown
      end
    end

    # Auto-detect format and decode to UUID
    #
    # @param str [String] Base58 or Base62 encoded string
    # @return [String] UUID with dashes
    # @raise [Error] if the format cannot be detected or string is invalid
    def self.decode(str)
      detected = format?(str)
      case detected
      when :base58 then from_base58(str)
      when :base62 then from_base62(str)
      else raise Error, "Unable to detect format of: #{str}"
      end
    end

    # Safer variant of `.decode` that only succeeds when the detected encoding
    # matches the expected format. Use when consuming IDs that should be a
    # specific encoding to prevent silent confusion between Base58 and Base62.
    #
    # @param str [String]
    # @param expected_format [Symbol] :base58 or :base62
    # @return [String] decoded UUID
    # @raise [Error] if the detected format does not match
    # @raise [ArgumentError] if expected_format is not a known format
    def self.decode_safe(str, expected_format:)
      unless %i[base58 base62].include?(expected_format)
        raise ArgumentError, "unknown expected_format: #{expected_format.inspect}"
      end

      detected = format?(str)
      raise Error, "expected #{expected_format} but got #{detected}" unless detected == expected_format

      expected_format == :base58 ? from_base58(str) : from_base62(str)
    end

    # Generate a compact ID with a type prefix
    #
    # @param prefix [String] type prefix (e.g. 'usr', 'ord', 'txn')
    # @param format [Symbol] :base58 or :base62
    # @param separator [String] character between prefix and ID (default '_')
    # @return [String] prefixed compact ID (e.g. 'usr_6fpBHktS7sqEUqhp4E2nE4')
    # @raise [Error] if prefix or separator is invalid
    def self.generate_prefixed(prefix, format: :base58, separator: '_')
      validate_prefix!(prefix)
      validate_separator!(separator)
      "#{prefix}#{separator}#{generate(format)}"
    end

    # Parse a prefixed compact ID into its components
    #
    # @param str [String] prefixed compact ID (e.g. 'usr_6fpBHktS7sqEUqhp4E2nE4')
    # @param separator [String] character between prefix and ID (default '_')
    # @return [Hash] { prefix:, id:, uuid: }
    # @raise [Error] if the string has no separator or the ID cannot be decoded
    def self.parse_prefixed(str, separator: '_')
      raise Error, 'Expected a non-empty String' unless str.is_a?(String) && !str.empty?

      parts = str.split(separator, 2)
      raise Error, "No separator '#{separator}' found in: #{str}" if parts.length < 2 || parts[1].empty?

      prefix = parts[0]
      id = parts[1]
      uuid = decode(id)

      { prefix: prefix, id: id, uuid: uuid }
    end

    # Check if a string is valid Base58
    #
    # @param str [String] string to validate
    # @return [Boolean]
    def self.valid_base58?(str)
      return false unless str.is_a?(String) && !str.empty?

      str.each_char.all? { |c| BASE58_ALPHABET.include?(c) }
    end

    # Check if a string is valid Base62
    #
    # @param str [String] string to validate
    # @return [Boolean]
    def self.valid_base62?(str)
      return false unless str.is_a?(String) && !str.empty?

      str.each_char.all? { |c| BASE62_ALPHABET.include?(c) }
    end

    PREFIX_PATTERN = /\A[a-zA-Z0-9]+\z/

    # @api private
    def self.validate_prefix!(prefix)
      raise Error, 'Prefix must be a non-empty String' unless prefix.is_a?(String) && !prefix.empty?
      raise Error, "Prefix must be alphanumeric: #{prefix}" unless prefix.match?(PREFIX_PATTERN)
    end
    private_class_method :validate_prefix!

    # @api private
    def self.validate_separator!(separator)
      raise Error, 'Separator must be a single character' unless separator.is_a?(String) && separator.length == 1
      raise Error, 'Separator must not be alphanumeric' if separator.match?(/[a-zA-Z0-9]/)
    end
    private_class_method :validate_separator!

    # @api private
    def self.validate_uuid!(uuid)
      raise Error, 'Invalid UUID format' unless uuid.is_a?(String) && uuid.match?(UUID_PATTERN)
    end
    private_class_method :validate_uuid!

    # @api private
    def self.uuid_to_int(uuid)
      uuid.delete('-').to_i(16)
    end
    private_class_method :uuid_to_int

    # @api private
    def self.int_to_uuid(num)
      hex = num.to_s(16).rjust(32, '0')
      format(
        '%<a>s-%<b>s-%<c>s-%<d>s-%<e>s',
        a: hex[0..7], b: hex[8..11], c: hex[12..15], d: hex[16..19], e: hex[20..31]
      )
    end
    private_class_method :int_to_uuid

    # @api private
    def self.encode(num, alphabet, pad_length)
      base = alphabet.length
      result = []

      while num.positive?
        num, remainder = num.divmod(base)
        result.unshift(alphabet[remainder])
      end

      result.join.rjust(pad_length, alphabet[0])
    end
    private_class_method :encode

    # @api private
    def self.decode_str(str, alphabet)
      base = alphabet.length
      str.each_char.reduce(0) do |num, char|
        index = alphabet.index(char)
        raise Error, "Invalid character: #{char}" if index.nil?

        (num * base) + index
      end
    end
    private_class_method :decode_str
  end
end
