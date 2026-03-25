# philiprehberger-compact_id

[![Tests](https://github.com/philiprehberger/rb-compact-id/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-compact-id/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-compact_id.svg)](https://rubygems.org/gems/philiprehberger-compact_id)
[![License](https://img.shields.io/github/license/philiprehberger/rb-compact-id)](LICENSE)

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
| `.generate(format)` | Generate a new UUID and encode it (`:base58` or `:base62`) |
| `.valid_base58?(str)` | Check if a string contains only valid Base58 characters |
| `.valid_base62?(str)` | Check if a string contains only valid Base62 characters |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
