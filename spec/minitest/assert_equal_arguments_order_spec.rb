# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts assert_equal arguments order' do
  let(:rewriter_name) { 'minitest/assert_equal_arguments_order' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert_equal(actual, "rubocop-minitest")
  EOS

  let(:test_rewritten_content) { <<~EOS }
    assert_equal("rubocop-minitest", actual)
  EOS

  include_examples 'convertable'
end
