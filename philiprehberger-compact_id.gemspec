# frozen_string_literal: true

require_relative 'lib/philiprehberger/compact_id/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-compact_id'
  spec.version = Philiprehberger::CompactId::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'Compact UUID encoding in Base58 and Base62 for shorter, URL-safe identifiers'
  spec.description = 'Convert UUIDs to compact Base58 or Base62 representations (22 chars vs 36). ' \
                       'Guaranteed roundtrip encoding, URL-safe output, and built-in UUID generation.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-compact_id'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-compact-id'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-compact-id/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-compact-id/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
