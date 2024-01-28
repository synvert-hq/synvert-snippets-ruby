# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Upgrade rails from 2.3 to 3.0' do
  let(:rewriter_name) { 'rails/upgrade_2_3_to_3_0' }
  let(:application_controller_content) { <<~EOS }
    class ApplicationController < ActionController::Base
      filter_parameter_logging :password, :password_confirmation
    end
  EOS

  let(:application_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
      end
    end
  EOS

  let(:application_controller_rewritten_content) { <<~EOS }
    class ApplicationController < ActionController::Base
    end
  EOS

  let(:application_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.filter_parameters += [:password, :password_confirmation]
      end
    end
  EOS

  let(:fake_file_paths) { %w[config/application.rb app/controllers/application_controller.rb] }
  let(:test_contents) { [application_content, application_controller_content] }
  let(:test_rewritten_contents) { [application_rewritten_content, application_controller_rewritten_content] }

  before do
    load_sub_snippets(
      %w[
        rails/convert_rails_env
        rails/convert_rails_root
        rails/convert_rails_logger
        rails/convert_dynamic_finders_for_rails_3
        rails/convert_mailers_2_3_to_3_0
        rails/convert_models_2_3_to_3_0
        rails/convert_routes_2_3_to_3_0
        rails/convert_views_2_3_to_3_0
      ]
    )
  end

  include_examples 'convertable with multiple files'
end
