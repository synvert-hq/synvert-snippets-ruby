# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails configs from 7.0 to 7.1' do
  let(:rewriter_name) { 'rails/convert_configs_7_0_to_7_1' }
  let(:application_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.load_defaults 7.0
      end
    end
  EOS
  let(:application_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.load_defaults 7.1
      end
    end
  EOS
  let(:production_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.action_dispatch.show_exceptions = true
      end
    end
  EOS
  let(:production_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.action_dispatch.show_exceptions = :all
      end
    end
  EOS
  let(:test_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.action_dispatch.show_exceptions = false
      end
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.action_dispatch.show_exceptions = :none
      end
    end
  EOS
  let(:fake_file_paths) { %w[config/application.rb config/environments/production.rb config/environments/test.rb] }
  let(:test_contents) { [application_content, production_content, test_content] }
  let(:test_rewritten_contents) {
    [
      application_rewritten_content,
      production_rewritten_content,
      test_rewritten_content
    ]
  }
  before { load_helpers(%w[helpers/set_rails_load_defaults.rb]) }

  include_examples 'convertable with multiple files'
end
