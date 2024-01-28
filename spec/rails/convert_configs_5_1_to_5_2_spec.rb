# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails configs from 5.1 to 5.2' do
  let(:rewriter_name) { 'rails/convert_configs_5_1_to_5_2' }
  let(:fake_file_path) { 'config/application.rb' }
  let(:test_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.load_defaults 5.1
        config.cache_store = :dalli_store, 'cache-1.example.com', 'cache-2.example.com'
      end
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.load_defaults 5.2
        config.cache_store = :mem_cache_store, 'cache-1.example.com', 'cache-2.example.com'
      end
    end
  EOS
  before { load_helpers(%w[helpers/set_rails_load_defaults]) }

  include_examples 'convertable'
end
