# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts assert_empty' do
  let(:rewriter_name) { 'minitest/assert_empty' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert(object.empty?)
  EOS

  let(:test_rewritten_content) { <<~EOS }
    assert_empty(object)
  EOS

  include_examples 'convertable'
end