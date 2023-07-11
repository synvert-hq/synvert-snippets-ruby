# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Upgrade rails from 5.2 to 6.0' do
  let(:rewriter_name) { 'rails/upgrade_5_2_to_6_0' }
  let(:fake_file_path) { 'config/application.rb' }
  let(:test_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.load_defaults 5.2
      end
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.load_defaults 6.0
      end
    end
  EOS
  before do
    load_sub_snippets(%w[rails/convert_update_attributes_to_update])
    load_sub_snippets(%w[rails/prefer_nor_conditions])
    load_helpers(%w[helpers/set_rails_load_defaults.rb])
  end

  include_examples 'convertable'
end
