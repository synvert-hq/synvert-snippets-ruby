# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Upgrade rails from 5.1 to 5.2' do
  let(:rewriter_name) { 'rails/upgrade_5_1_to_5_2' }
  let(:application_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.cache_store = :dalli_store, 'cache-1.example.com', 'cache-2.example.com'
      end
    end
  EOS

  let(:application_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.cache_store = :mem_cache_store, 'cache-1.example.com', 'cache-2.example.com'
      end
    end
  EOS

  let(:fake_file_paths) { ['config/application.rb'] }
  let(:test_contents) { [application_content] }
  let(:test_rewritten_contents) { [application_rewritten_content] }

  include_examples 'convertable with multiple files'
end
