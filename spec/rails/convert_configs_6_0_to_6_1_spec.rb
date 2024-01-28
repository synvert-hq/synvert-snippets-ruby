# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails configs from 6.0 to 6.1' do
  let(:rewriter_name) { 'rails/convert_configs_6_0_to_6_1' }
  let(:fake_file_path) { 'config/application.rb' }
  let(:test_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.load_defaults 6.0
      end
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.load_defaults 6.1
      end
    end
  EOS
  before { load_helpers(%w[helpers/set_rails_load_defaults.rb]) }

  include_examples 'convertable'
end
