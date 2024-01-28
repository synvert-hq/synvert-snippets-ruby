# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails configs from 5.0 to 5.1' do
  let(:rewriter_name) { 'rails/convert_configs_5_0_to_5_1' }
  let(:fake_file_path) { 'config/application.rb' }
  let(:test_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.load_defaults 5.0
      end
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.load_defaults 5.1
      end
    end
  EOS

  before do
    load_sub_snippets(%w[rails/convert_active_record_dirty_5_0_to_5_1])
    load_helpers(%w[helpers/set_rails_load_defaults])
  end

  include_examples 'convertable'
end
