# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails configs from 3.1 to 3.2' do
  let(:rewriter_name) { 'rails/convert_configs_3_1_to_3_2' }
  let(:development_content) { <<~EOS }
    Synvert::Application.configure do
    end
  EOS

  let(:development_rewritten_content) { <<~EOS }
    Synvert::Application.configure do
      config.active_record.mass_assignment_sanitizer = :strict
      config.active_record.auto_explain_threshold_in_seconds = 0.5
    end
  EOS

  let(:test_content) { <<~EOS }
    Synvert::Application.configure do
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    Synvert::Application.configure do
      config.active_record.mass_assignment_sanitizer = :strict
    end
  EOS

  let(:fake_file_paths) { %w[config/environments/development.rb config/environments/test.rb] }
  let(:test_contents) { [development_content, test_content] }
  let(:test_rewritten_contents) { [development_rewritten_content, test_rewritten_content] }

  include_examples 'convertable with multiple files'
end
