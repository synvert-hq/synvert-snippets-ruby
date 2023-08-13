# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts refute_same' do
  let(:rewriter_name) { 'minitest/refute_same' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    refute(expected.equal?(actual))
    assert(!expected.equal?(actual))
  EOS

  let(:test_rewritten_content) { <<~EOS }
    refute_same(expected, actual)
    refute_same(expected, actual)
  EOS

  include_examples 'convertable'
end
