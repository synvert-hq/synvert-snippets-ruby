# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Upgrade rails from 3.1 to 3.2' do
  let(:rewriter_name) { 'rails/upgrade_3_1_to_3_2' }
  let(:development_content) {
    '
Synvert::Application.configure do
end
  '
  }
  let(:development_rewritten_content) {
    '
Synvert::Application.configure do
  config.active_record.mass_assignment_sanitizer = :strict
  config.active_record.auto_explain_threshold_in_seconds = 0.5
end
  '
  }
  let(:test_content) {
    '
Synvert::Application.configure do
end
  '
  }
  let(:test_rewritten_content) {
    '
Synvert::Application.configure do
  config.active_record.mass_assignment_sanitizer = :strict
end
  '
  }
  let(:fake_file_paths) { %w[config/environments/development.rb config/environments/test.rb] }
  let(:test_contents) { [development_content, test_content] }
  let(:test_rewritten_contents) { [development_rewritten_content, test_rewritten_content] }

  before do
    load_sub_snippets(%w[rails/fix_controller_3_2_deprecations rails/fix_model_3_2_deprecations])
  end

  include_examples 'convertable with multiple files'
end
