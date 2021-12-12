# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts refute_match' do
  let(:rewriter_name) { 'minitest/refute_match' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert(!pattern.match?(object))
    refute(pattern.match?(object))
  EOS

  let(:test_rewritten_content) { <<~EOS }
    refute_match(pattern, object)
    refute_match(pattern, object)
  EOS

  include_examples 'convertable'
end