# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts assert_instance_of' do
  let(:rewriter_name) { 'minitest/assert_instance_of' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert('rubocop-minitest'.instance_of?(String))
  EOS

  let(:test_rewritten_content) { <<~EOS }
    assert_instance_of(String, 'rubocop-minitest')
  EOS

  include_examples 'convertable'
end
