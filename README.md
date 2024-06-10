# philiprehberger-compact_id

[![Tests](https://github.com/philiprehberger/rb-compact-id/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-compact-id/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-compact_id.svg)](https://rubygems.org/gems/philiprehberger-compact_id)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-compact-id)](https://github.com/philiprehberger/rb-compact-id/commits/main)

Compact UUID encoding in Base58 and Base62 for shorter, URL-safe identifiers

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-compact_id"
```

Or install directly:

```bash
gem install philiprehberger-compact_id
```

## Usage

```ruby
require "philiprehberger/compact_id"

uuid = '550e8400-e29b-41d4-a716-446655440000'

# Encode to Base58
encoded = Philiprehberger::CompactId.to_base58(uuid)
# => "6fpBHktS7sqEUqhp4E2nE4" (22 chars vs 36)

# Decode back to UUID
Philiprehberger::CompactId.from_base58(encoded)
# => "550e8400-e29b-41d4-a716-446655440000"
```

### Base62 Encoding

```ruby
encoded = Philiprehberger::CompactId.to_base62(uuid)
Philiprehberger::CompactId.from_base62(encoded)
```

### Generate Encoded UUIDs

```ruby
Philiprehberger::CompactId.generate(:base58)  # => new UUID as Base58
Philiprehberger::CompactId.generate(:base62)  # => new UUID as Base62
```

### Batch Operations

```ruby
# Generate multiple IDs at once
ids = Philiprehberger::CompactId.batch_generate(5)
ids = Philiprehberger::CompactId.batch_generate(5, format: :base62)

# Bulk encode arrays of UUIDs
uuids = [SecureRandom.uuid, SecureRandom.uuid]
Philiprehberger::CompactId.batch_to_base58(uuids)
Philiprehberger::CompactId.batch_to_base62(uuids)
```

### Cross-Format Conversion

```ruby
b58 = Philiprehberger::CompactId.to_base58(uuid)
b62 = Philiprehberger::CompactId.base58_to_base62(b58)  # direct, no intermediate UUID
b58 = Philiprehberger::CompactId.base62_to_base58(b62)
```

### Format Detection and Auto-Decode

```ruby
Philiprehberger::CompactId.format?('6fpBHktS7sqEUqhp4E2nE4')  # => :base58
Philiprehberger::CompactId.format?('0abc')                     # => :base62
Philiprehberger::CompactId.format?('!!!')                      # => :unknown

# Auto-detect and decode
Philiprehberger::CompactId.decode('6fpBHktS7sqEUqhp4E2nE4')
# => "550e8400-e29b-41d4-a716-446655440000"
```

### Validation

```ruby
Philiprehberger::CompactId.valid_base58?('6fpBHktS7sqEUqhp4E2nE4')  # => true
Philiprehberger::CompactId.valid_base58?('0OIl')                     # => false (invalid chars)
```

## API

### `Philiprehberger::CompactId`

| Method | Description |
|--------|-------------|
| `.to_base58(uuid)` | Encode a UUID as a Base58 string (22 chars) |
| `.to_base62(uuid)` | Encode a UUID as a Base62 string (22 chars) |
| `.from_base58(str)` | Decode a Base58 string back to a UUID |
| `.from_base62(str)` | Decode a Base62 string back to a UUID |
| `.generate(format = :base58)` | Generate a new UUID and encode it (`:base58` or `:base62`) |
| `.batch_generate(count, format: :base58)` | Generate multiple compact IDs at once |
| `.batch_to_base58(uuids)` | Bulk encode an array of UUIDs to Base58 |
| `.batch_to_base62(uuids)` | Bulk encode an array of UUIDs to Base62 |
| `.base58_to_base62(str)` | Convert a Base58 string directly to Base62 |
| `.base62_to_base58(str)` | Convert a Base62 string directly to Base58 |
| `.format?(str)` | Detect format: returns `:base58`, `:base62`, or `:unknown` |
| `.decode(str)` | Auto-detect format and decode to UUID |
| `.valid_base58?(str)` | Check if a string contains only valid Base58 characters |
| `.valid_base62?(str)` | Check if a string contains only valid Base62 characters |
| `Error` | Error class raised for invalid UUIDs or characters |
| `BASE58_ALPHABET` | Character set used for Base58 encoding (excludes `0`, `O`, `I`, `l`) |
| `BASE62_ALPHABET` | Character set used for Base62 encoding (alphanumeric `0-9A-Za-z`) |
| `UUID_PATTERN` | Regex pattern used to validate UUID format |
| `VERSION` | Current gem version string |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-compact-id)

🐛 [Report issues](https://github.com/philiprehberger/rb-compact-id/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-compact-id/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
