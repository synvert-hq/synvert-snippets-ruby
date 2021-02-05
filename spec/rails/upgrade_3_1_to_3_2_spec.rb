# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Upgrade rails from 3.1 to 3.2' do
  let(:rewriter_name) { 'rails/upgrade_3_1_to_3_2' }
  let(:development_content) { '
Synvert::Application.configure do
end
  '}
  let(:development_rewritten_content) { '
Synvert::Application.configure do
  config.active_record.mass_assignment_sanitizer = :strict
  config.active_record.auto_explain_threshold_in_seconds = 0.5
end
  '}
  let(:test_content) { '
Synvert::Application.configure do
end
  '}
  let(:test_rewritten_content) { '
Synvert::Application.configure do
  config.active_record.mass_assignment_sanitizer = :strict
end
  '}
  let(:project_content) { '
class Project < ActiveRecord::Base
  set_table_name "project"
end
  '}
  let(:project_rewritten_content) { '
class Project < ActiveRecord::Base
  self.table_name = "project"
end
  '}
  let(:application_controller_content) { '
class ApplicationController < ActionController::Base
  rescue_from ActionController::UnknownAction, :with => :render_404
end
  '}
  let(:application_controller_rewritten_content) { '
class ApplicationController < ActionController::Base
  rescue_from AbstractController::ActionNotFound, :with => :render_404
end
  '}
  let(:fake_file_paths) { %w[config/environments/development.rb config/environments/test.rb app/models/project.rb app/controllers/application_controller.rb] }
  let(:test_contents) {[development_content, test_content, project_content, application_controller_content] }
  let(:test_rewritten_contents) {[development_rewritten_content, test_rewritten_content, project_rewritten_content, application_controller_rewritten_content] }

  include_examples 'convertable with multiple files'
end
