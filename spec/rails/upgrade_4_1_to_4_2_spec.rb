# encoding: utf-8

require 'spec_helper'

RSpec.describe 'Upgrade rails from 4.1 to 4.2' do
  let(:rewriter_name) { 'rails/upgrade_4_1_to_4_2' }
  let(:application_content) { '
module Synvert
  class Application < Rails::Application
  end
end
  '}
  let(:application_rewritten_content) { '
module Synvert
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true
  end
end
  '}
  let(:production_content) { '
module Synvert
  class Application < Rails::Application
    config.serve_static_assets = false
  end
end
  '}
  let(:production_rewritten_content) { '
module Synvert
  class Application < Rails::Application
    config.serve_static_files = false
  end
end
  '}
  let(:fake_file_paths) { %w[config/application.rb config/environments/production.rb] }
  let(:test_contents) { [application_content, production_content] }
  let(:test_rewritten_contents) { [application_rewritten_content, production_rewritten_content] }

  include_examples 'convertable with multiple files'
end
