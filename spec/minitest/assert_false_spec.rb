# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts assert_false' do
  let(:rewriter_name) { 'minitest/assert_false' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert_equal(false, actual)
    assert(!something)
  EOS

  let(:test_rewritten_content) { <<~EOS }
    refute(actual)
    refute(something)
  EOS

  include_examples 'convertable'
end
