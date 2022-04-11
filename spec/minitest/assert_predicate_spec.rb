# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts assert_predicate' do
  let(:rewriter_name) { 'minitest/assert_predicate' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert expected.zero?
    assert_equal 0, expected
  EOS

  let(:test_rewritten_content) { <<~EOS }
    assert_predicate expected, :zero?
    assert_predicate expected, :zero?
  EOS

  include_examples 'convertable'
end
