# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Bundler uses shortcut git source' do
  let(:rewriter_name) { 'bundler/use-shortcut-git-source' }
  let(:fake_file_path) { 'Gemfile' }
  let(:test_content) { <<~EOS }
    # frozen_string_literal: true

    source 'https://rubygems.org'

    gem 'nokogiri', '1.7.0.1', git: 'https://github.com/sparklemotion/nokogiri'
    gem 'nokogiri', '1.7.0.1', git: 'https://github.com/sparklemotion/nokogiri.git'
    gem 'nokogiri', '1.7.0.1', git: 'git://github.com/sparklemotion/nokogiri.git'
    gem 'nokogiri', '1.7.0.1', git: 'git@github.com:sparklemotion/nokogiri.git'
    gem 'rails', git: 'https://github.com/rails/rails.git'
    gem 'keystone', git: 'https://musicone@bitbucket.org/musicone/keystone.git'
    gem 'musicone', git: 'https://musicone@bitbucket.org/musicone/musicone.git'
    gem 'my_gist', git: 'https://gist.github.com/4815162342.git'
  EOS
  let(:test_rewritten_content) { <<~EOS }
    # frozen_string_literal: true

    source 'https://rubygems.org'

    gem 'nokogiri', '1.7.0.1', github: 'sparklemotion/nokogiri'
    gem 'nokogiri', '1.7.0.1', github: 'sparklemotion/nokogiri'
    gem 'nokogiri', '1.7.0.1', github: 'sparklemotion/nokogiri'
    gem 'nokogiri', '1.7.0.1', git: 'git@github.com:sparklemotion/nokogiri.git'
    gem 'rails', github: 'rails'
    gem 'keystone', bitbucket: 'musicone/keystone'
    gem 'musicone', bitbucket: 'musicone'
    gem 'my_gist', gist: '4815162342'
  EOS

  include_examples 'convertable'
end
