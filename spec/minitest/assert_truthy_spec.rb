# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts assert_truthy' do
  let(:rewriter_name) { 'minitest/assert_truthy' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert_equal(true, actual)
  EOS

  let(:test_rewritten_content) { <<~EOS }
    assert(actual)
  EOS

  include_examples 'convertable'
end