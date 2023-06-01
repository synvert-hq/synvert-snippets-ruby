# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Upgrade rails from 6.0 to 6.1' do
  let(:rewriter_name) { 'rails/upgrade_6_0_to_6_1' }
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
  before do
    load_sub_snippets(%w[rails/rename_errors_keys_to_attribute_names rails/deprecate_errors_as_hash])
    load_helpers(%w[helpers/set_rails_load_defaults.rb])
  end

  include_examples 'convertable'
end
