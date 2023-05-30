# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rename errors.keys to error.attribute_names' do
  let(:rewriter_name) { 'rails/rename_errors_keys_to_attribute_names' }
  let(:fake_file_path) { 'app/models/user.rb' }
  let(:test_content) { <<~EOS }
    user.errors.keys.include?(:name)
  EOS

  let(:test_rewritten_content) { <<~EOS }
    user.errors.attribute_names.include?(:name)
  EOS

  include_examples 'convertable'
end
