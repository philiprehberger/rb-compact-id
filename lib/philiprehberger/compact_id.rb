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
      int_to_uuid(decode(str, BASE58_ALPHABET))
    end

    # Decode a Base62 string back to a UUID
    #
    # @param str [String] Base62-encoded string
    # @return [String] UUID with dashes
    # @raise [Error] if the string contains invalid characters
    def self.from_base62(str)
      int_to_uuid(decode(str, BASE62_ALPHABET))
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
    def self.decode(str, alphabet)
      base = alphabet.length
      str.each_char.reduce(0) do |num, char|
        index = alphabet.index(char)
        raise Error, "Invalid character: #{char}" if index.nil?

        (num * base) + index
      end
    end
    private_class_method :decode
  end
end
