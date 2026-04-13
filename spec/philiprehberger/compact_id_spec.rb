# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::CompactId do
  let(:uuid) { '550e8400-e29b-41d4-a716-446655440000' }
  let(:nil_uuid) { '00000000-0000-0000-0000-000000000000' }
  let(:max_uuid) { 'ffffffff-ffff-ffff-ffff-ffffffffffff' }

  it 'has a version number' do
    expect(Philiprehberger::CompactId::VERSION).not_to be_nil
  end

  describe '.to_base58' do
    it 'encodes a UUID to base58' do
      result = described_class.to_base58(uuid)
      expect(result).to be_a(String)
      expect(result.length).to eq(22)
    end

    it 'produces only valid base58 characters' do
      result = described_class.to_base58(uuid)
      expect(described_class.valid_base58?(result)).to be true
    end

    it 'raises on invalid UUID' do
      expect { described_class.to_base58('not-a-uuid') }.to raise_error(Philiprehberger::CompactId::Error)
    end

    it 'encodes the nil UUID' do
      result = described_class.to_base58(nil_uuid)
      expect(result.length).to eq(22)
    end

    it 'encodes the max UUID' do
      result = described_class.to_base58(max_uuid)
      expect(result.length).to eq(22)
    end
  end

  describe '.to_base62' do
    it 'encodes a UUID to base62' do
      result = described_class.to_base62(uuid)
      expect(result).to be_a(String)
      expect(result.length).to eq(22)
    end

    it 'produces only valid base62 characters' do
      result = described_class.to_base62(uuid)
      expect(described_class.valid_base62?(result)).to be true
    end

    it 'raises on invalid UUID' do
      expect { described_class.to_base62(123) }.to raise_error(Philiprehberger::CompactId::Error)
    end
  end

  describe '.from_base58' do
    it 'decodes a base58 string back to a UUID' do
      encoded = described_class.to_base58(uuid)
      decoded = described_class.from_base58(encoded)
      expect(decoded).to eq(uuid.downcase)
    end

    it 'raises on invalid characters' do
      expect { described_class.from_base58('0OIl') }.to raise_error(Philiprehberger::CompactId::Error)
    end
  end

  describe '.from_base62' do
    it 'decodes a base62 string back to a UUID' do
      encoded = described_class.to_base62(uuid)
      decoded = described_class.from_base62(encoded)
      expect(decoded).to eq(uuid.downcase)
    end
  end

  describe 'roundtrip' do
    it 'roundtrips UUID through base58' do
      encoded = described_class.to_base58(uuid)
      decoded = described_class.from_base58(encoded)
      expect(decoded).to eq(uuid.downcase)
    end

    it 'roundtrips UUID through base62' do
      encoded = described_class.to_base62(uuid)
      decoded = described_class.from_base62(encoded)
      expect(decoded).to eq(uuid.downcase)
    end

    it 'roundtrips nil UUID through base58' do
      encoded = described_class.to_base58(nil_uuid)
      decoded = described_class.from_base58(encoded)
      expect(decoded).to eq(nil_uuid)
    end

    it 'roundtrips max UUID through base58' do
      encoded = described_class.to_base58(max_uuid)
      decoded = described_class.from_base58(encoded)
      expect(decoded).to eq(max_uuid)
    end

    it 'roundtrips random UUIDs through base58' do
      5.times do
        random_uuid = SecureRandom.uuid
        encoded = described_class.to_base58(random_uuid)
        decoded = described_class.from_base58(encoded)
        expect(decoded).to eq(random_uuid.downcase)
      end
    end

    it 'roundtrips random UUIDs through base62' do
      5.times do
        random_uuid = SecureRandom.uuid
        encoded = described_class.to_base62(random_uuid)
        decoded = described_class.from_base62(encoded)
        expect(decoded).to eq(random_uuid.downcase)
      end
    end
  end

  describe '.generate' do
    it 'generates a base58-encoded UUID by default' do
      result = described_class.generate
      expect(described_class.valid_base58?(result)).to be true
    end

    it 'generates a base58-encoded UUID explicitly' do
      result = described_class.generate(:base58)
      expect(described_class.valid_base58?(result)).to be true
      decoded = described_class.from_base58(result)
      expect(decoded).to match(Philiprehberger::CompactId::UUID_PATTERN)
    end

    it 'generates a base62-encoded UUID' do
      result = described_class.generate(:base62)
      expect(described_class.valid_base62?(result)).to be true
      decoded = described_class.from_base62(result)
      expect(decoded).to match(Philiprehberger::CompactId::UUID_PATTERN)
    end

    it 'raises on unknown format' do
      expect { described_class.generate(:base64) }.to raise_error(Philiprehberger::CompactId::Error)
    end

    it 'generates unique values' do
      results = Array.new(10) { described_class.generate }
      expect(results.uniq.length).to eq(10)
    end
  end

  describe '.batch_generate' do
    it 'generates the requested number of base58 IDs by default' do
      results = described_class.batch_generate(5)
      expect(results).to be_an(Array)
      expect(results.length).to eq(5)
      results.each { |id| expect(described_class.valid_base58?(id)).to be true }
    end

    it 'generates base62 IDs when specified' do
      results = described_class.batch_generate(3, format: :base62)
      expect(results.length).to eq(3)
      results.each { |id| expect(described_class.valid_base62?(id)).to be true }
    end

    it 'generates unique values' do
      results = described_class.batch_generate(10)
      expect(results.uniq.length).to eq(10)
    end

    it 'raises on non-positive count' do
      expect { described_class.batch_generate(0) }.to raise_error(Philiprehberger::CompactId::Error)
      expect { described_class.batch_generate(-1) }.to raise_error(Philiprehberger::CompactId::Error)
    end

    it 'raises on non-integer count' do
      expect { described_class.batch_generate('5') }.to raise_error(Philiprehberger::CompactId::Error)
    end
  end

  describe '.sortable_id' do
    it 'generates a base62-encoded sortable ID by default' do
      result = described_class.sortable_id
      expect(result).to be_a(String)
      expect(described_class.valid_base62?(result)).to be true
    end

    it 'generates a base58-encoded sortable ID' do
      result = described_class.sortable_id(format: :base58)
      expect(result).to be_a(String)
      expect(described_class.valid_base58?(result)).to be true
    end

    it 'generates unique values' do
      results = Array.new(10) { described_class.sortable_id }
      expect(results.uniq.length).to eq(10)
    end

    it 'produces IDs that sort chronologically' do
      first = described_class.sortable_id
      sleep(0.002)
      second = described_class.sortable_id
      expect(second > first).to be true
    end

    it 'produces IDs that sort chronologically in base58' do
      first = described_class.sortable_id(format: :base58)
      sleep(0.002)
      second = described_class.sortable_id(format: :base58)
      expect(second > first).to be true
    end

    it 'raises on unsupported format' do
      expect { described_class.sortable_id(format: :base64) }.to raise_error(Philiprehberger::CompactId::Error)
    end
  end

  describe '.batch_to_base58' do
    it 'encodes an array of UUIDs to base58' do
      uuids = Array.new(3) { SecureRandom.uuid }
      results = described_class.batch_to_base58(uuids)
      expect(results.length).to eq(3)
      results.each_with_index do |encoded, i|
        expect(described_class.from_base58(encoded)).to eq(uuids[i].downcase)
      end
    end

    it 'returns an empty array for empty input' do
      expect(described_class.batch_to_base58([])).to eq([])
    end

    it 'raises on non-array input' do
      expect { described_class.batch_to_base58('not-an-array') }.to raise_error(Philiprehberger::CompactId::Error)
    end

    it 'raises if any UUID is invalid' do
      expect { described_class.batch_to_base58([uuid, 'bad']) }.to raise_error(Philiprehberger::CompactId::Error)
    end
  end

  describe '.batch_to_base62' do
    it 'encodes an array of UUIDs to base62' do
      uuids = Array.new(3) { SecureRandom.uuid }
      results = described_class.batch_to_base62(uuids)
      expect(results.length).to eq(3)
      results.each_with_index do |encoded, i|
        expect(described_class.from_base62(encoded)).to eq(uuids[i].downcase)
      end
    end

    it 'returns an empty array for empty input' do
      expect(described_class.batch_to_base62([])).to eq([])
    end

    it 'raises on non-array input' do
      expect { described_class.batch_to_base62(nil) }.to raise_error(Philiprehberger::CompactId::Error)
    end
  end

  describe '.base58_to_base62' do
    it 'converts a base58 string to base62' do
      b58 = described_class.to_base58(uuid)
      b62 = described_class.base58_to_base62(b58)
      expect(described_class.valid_base62?(b62)).to be true
      expect(described_class.from_base62(b62)).to eq(uuid.downcase)
    end

    it 'roundtrips through base62 and back' do
      b58 = described_class.to_base58(uuid)
      b62 = described_class.base58_to_base62(b58)
      back = described_class.base62_to_base58(b62)
      expect(back).to eq(b58)
    end

    it 'raises on invalid base58 characters' do
      expect { described_class.base58_to_base62('0OIl') }.to raise_error(Philiprehberger::CompactId::Error)
    end
  end

  describe '.base62_to_base58' do
    it 'converts a base62 string to base58' do
      b62 = described_class.to_base62(uuid)
      b58 = described_class.base62_to_base58(b62)
      expect(described_class.valid_base58?(b58)).to be true
      expect(described_class.from_base58(b58)).to eq(uuid.downcase)
    end

    it 'raises on invalid base62 characters' do
      expect { described_class.base62_to_base58('!!!') }.to raise_error(Philiprehberger::CompactId::Error)
    end
  end

  describe '.format?' do
    it 'detects base58 strings' do
      b58 = described_class.to_base58(uuid)
      expect(described_class.format?(b58)).to eq(:base58)
    end

    it 'detects base62 strings containing base62-only characters' do
      # Use a string with '0' which is in base62 but not base58
      expect(described_class.format?('0abc')).to eq(:base62)
    end

    it 'returns :unknown for strings with special characters' do
      expect(described_class.format?('abc+def')).to eq(:unknown)
    end

    it 'returns :unknown for empty strings' do
      expect(described_class.format?('')).to eq(:unknown)
    end

    it 'returns :unknown for nil' do
      expect(described_class.format?(nil)).to eq(:unknown)
    end
  end

  describe '.decode' do
    it 'auto-decodes a base58 string' do
      b58 = described_class.to_base58(uuid)
      expect(described_class.decode(b58)).to eq(uuid.downcase)
    end

    it 'auto-decodes a base62 string containing base62-only characters' do
      b62 = described_class.to_base62(uuid)
      # If b62 happens to be valid base58 too, it will decode via base58 which is fine
      # since both decode to the same UUID
      decoded = described_class.decode(b62)
      expect(decoded).to eq(uuid.downcase)
    end

    it 'raises on undetectable format' do
      expect { described_class.decode('!!!') }.to raise_error(Philiprehberger::CompactId::Error)
    end

    it 'raises on empty string' do
      expect { described_class.decode('') }.to raise_error(Philiprehberger::CompactId::Error)
    end

    it 'roundtrips random UUIDs through generate and decode' do
      5.times do
        generated = described_class.generate(:base58)
        decoded = described_class.decode(generated)
        expect(decoded).to match(Philiprehberger::CompactId::UUID_PATTERN)
      end
    end
  end

  describe '.generate_prefixed' do
    it 'generates a prefixed base58 ID by default' do
      result = described_class.generate_prefixed('usr')
      expect(result).to start_with('usr_')
      id = result.split('_', 2).last
      expect(described_class.valid_base58?(id)).to be true
    end

    it 'generates a prefixed base62 ID' do
      result = described_class.generate_prefixed('ord', format: :base62)
      expect(result).to start_with('ord_')
      id = result.split('_', 2).last
      expect(described_class.valid_base62?(id)).to be true
    end

    it 'supports a custom separator' do
      result = described_class.generate_prefixed('txn', separator: '-')
      expect(result).to start_with('txn-')
    end

    it 'raises on empty prefix' do
      expect { described_class.generate_prefixed('') }.to raise_error(Philiprehberger::CompactId::Error)
    end

    it 'raises on nil prefix' do
      expect { described_class.generate_prefixed(nil) }.to raise_error(Philiprehberger::CompactId::Error)
    end

    it 'raises on non-alphanumeric prefix' do
      expect { described_class.generate_prefixed('us-r') }.to raise_error(Philiprehberger::CompactId::Error)
    end

    it 'raises on alphanumeric separator' do
      expect { described_class.generate_prefixed('usr', separator: 'a') }.to raise_error(Philiprehberger::CompactId::Error)
    end

    it 'generates unique values' do
      results = Array.new(10) { described_class.generate_prefixed('usr') }
      expect(results.uniq.length).to eq(10)
    end
  end

  describe '.parse_prefixed' do
    it 'parses a prefixed base58 ID' do
      prefixed = described_class.generate_prefixed('usr')
      result = described_class.parse_prefixed(prefixed)
      expect(result[:prefix]).to eq('usr')
      expect(result[:id]).to be_a(String)
      expect(result[:uuid]).to match(Philiprehberger::CompactId::UUID_PATTERN)
    end

    it 'parses a prefixed base62 ID' do
      prefixed = described_class.generate_prefixed('ord', format: :base62)
      result = described_class.parse_prefixed(prefixed)
      expect(result[:prefix]).to eq('ord')
      expect(result[:uuid]).to match(Philiprehberger::CompactId::UUID_PATTERN)
    end

    it 'parses with a custom separator' do
      prefixed = described_class.generate_prefixed('txn', separator: '-')
      result = described_class.parse_prefixed(prefixed, separator: '-')
      expect(result[:prefix]).to eq('txn')
      expect(result[:uuid]).to match(Philiprehberger::CompactId::UUID_PATTERN)
    end

    it 'roundtrips through generate and parse' do
      prefixed = described_class.generate_prefixed('usr', format: :base58)
      parsed = described_class.parse_prefixed(prefixed)
      re_encoded = described_class.to_base58(parsed[:uuid])
      expect(re_encoded).to eq(parsed[:id])
    end

    it 'raises on string without separator' do
      expect { described_class.parse_prefixed('noseparator') }.to raise_error(Philiprehberger::CompactId::Error)
    end

    it 'raises on empty string' do
      expect { described_class.parse_prefixed('') }.to raise_error(Philiprehberger::CompactId::Error)
    end

    it 'raises on nil' do
      expect { described_class.parse_prefixed(nil) }.to raise_error(Philiprehberger::CompactId::Error)
    end

    it 'raises when ID portion is empty' do
      expect { described_class.parse_prefixed('usr_') }.to raise_error(Philiprehberger::CompactId::Error)
    end
  end

  describe '.valid_base58?' do
    it 'returns true for valid base58 strings' do
      expect(described_class.valid_base58?('123ABCabc')).to be true
    end

    it 'returns false for strings with invalid characters' do
      expect(described_class.valid_base58?('0OIl')).to be false
    end

    it 'returns false for empty strings' do
      expect(described_class.valid_base58?('')).to be false
    end

    it 'returns false for nil' do
      expect(described_class.valid_base58?(nil)).to be false
    end
  end

  describe '.valid_base62?' do
    it 'returns true for valid base62 strings' do
      expect(described_class.valid_base62?('0123ABCabc')).to be true
    end

    it 'returns false for strings with special characters' do
      expect(described_class.valid_base62?('abc+def')).to be false
    end

    it 'returns false for empty strings' do
      expect(described_class.valid_base62?('')).to be false
    end

    it 'returns false for nil' do
      expect(described_class.valid_base62?(nil)).to be false
    end
  end
end
