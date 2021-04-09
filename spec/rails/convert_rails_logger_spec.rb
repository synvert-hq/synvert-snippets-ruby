# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Upgrade RAILS_DEFAULT_LOGGER to Rails.logger' do
  let(:rewriter_name) { 'rails/convert_rails_logger' }
  let(:fake_file_path) { 'config/initializers/constant.rb' }
  let(:test_content) { <<~EOS }
    RAILS_DEFAULT_LOGGER
    ::RAILS_DEFAULT_LOGGER
  EOS

  let(:test_rewritten_content) { <<~EOS }
    Rails.logger
    Rails.logger
  EOS

  include_examples 'convertable'
end
