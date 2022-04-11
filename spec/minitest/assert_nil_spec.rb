# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts assert_nil' do
  let(:rewriter_name) { 'minitest/assert_nil' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert_equal(nil, actual)
  EOS

  let(:test_rewritten_content) { <<~EOS }
    assert_nil(actual)
  EOS

  include_examples 'convertable'
end
