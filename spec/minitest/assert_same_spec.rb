# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts assert_same' do
  let(:rewriter_name) { 'minitest/assert_same' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert(expected.equal?(actual))
  EOS

  let(:test_rewritten_content) { <<~EOS }
    assert_same(expected, actual)
  EOS

  include_examples 'convertable'
end
