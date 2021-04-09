# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert RAILS_ENV to Rails.env' do
  let(:rewriter_name) { 'rails/convert_rails_env' }
  let(:fake_file_path) { 'config/initializers/constant.rb' }
  let(:test_content) { <<~EOS }
    RAILS_ENV
    ::RAILS_ENV
    RAILS_ENV == 'test'
    'development' == RAILS_ENV
    RAILS_ENV != 'test'
    'development' != RAILS_ENV
  EOS

  let(:test_rewritten_content) { <<~EOS }
    Rails.env
    Rails.env
    Rails.env.test?
    Rails.env.development?
    !Rails.env.test?
    !Rails.env.development?
  EOS

  include_examples 'convertable'
end
