# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails configs from 4.1 to 4.2' do
  let(:rewriter_name) { 'rails/convert_configs_4_1_to_4_2' }
  let(:application_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
      end
    end
  EOS

  let(:application_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.active_record.raise_in_transactional_callbacks = true
      end
    end
  EOS

  let(:production_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.serve_static_assets = false
      end
    end
  EOS

  let(:production_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.serve_static_files = false
      end
    end
  EOS

  let(:fake_file_paths) { %w[config/application.rb config/environments/production.rb] }
  let(:test_contents) { [application_content, production_content] }
  let(:test_rewritten_contents) { [application_rewritten_content, production_rewritten_content] }

  include_examples 'convertable with multiple files'
end
