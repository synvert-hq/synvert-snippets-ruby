# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Upgrade rails configs from 2.3 to 3.0' do
  let(:rewriter_name) { 'rails/convert_configs_2_3_to_3_0' }
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

  include_examples 'convertable with multiple files'
end
