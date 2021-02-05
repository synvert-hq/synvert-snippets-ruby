require 'spec_helper'

RSpec.describe 'Upgrade rails from 2.3 to 3.0' do
  let(:rewriter_name) { 'rails/upgrade_2_3_to_3_0' }
  let(:application_controller_content) {
    '
class ApplicationController < ActionController::Base
  filter_parameter_logging :password, :password_confirmation
end
  '
  }
  let(:application_content) {
    '
module Synvert
  class Application < Rails::Application
  end
end
  '
  }
  let(:application_controller_rewritten_content) {
    '
class ApplicationController < ActionController::Base
end
  '
  }
  let(:application_rewritten_content) {
    '
module Synvert
  class Application < Rails::Application
    config.filter_parameters += [:password, :password_confirmation]
  end
end
  '
  }
  let(:fake_file_paths) { %w[config/application.rb app/controllers/application_controller.rb] }
  let(:test_contents) { [application_content, application_controller_content] }
  let(:test_rewritten_contents) { [application_rewritten_content, application_controller_rewritten_content] }

  before do
    load_sub_snippets(
      %w[
        rails/convert_rails_env
        rails/convert_rails_root
        rails/convert_rails_logger
        rails/convert_mailers_2_3_to_3_0
        rails/convert_models_2_3_to_3_0
        rails/convert_routes_2_3_to_3_0
        rails/convert_views_2_3_to_3_0
      ]
    )
  end

  include_examples 'convertable with multiple files'
end
