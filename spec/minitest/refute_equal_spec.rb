# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts refute_equal' do
  let(:rewriter_name) { 'minitest/refute_equal' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert("rubocop-minitest" != actual)
    assert(!"rubocop-minitest" == actual)
  EOS

  let(:test_rewritten_content) { <<~EOS }
    refute_equal("rubocop-minitest", actual)
    refute_equal("rubocop-minitest", actual)
  EOS

  include_examples 'convertable'
end