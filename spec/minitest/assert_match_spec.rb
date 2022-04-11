# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts assert_match' do
  let(:rewriter_name) { 'minitest/assert_match' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert(pattern.match?(object))
  EOS

  let(:test_rewritten_content) { <<~EOS }
    assert_match(pattern, object)
  EOS

  include_examples 'convertable'
end
