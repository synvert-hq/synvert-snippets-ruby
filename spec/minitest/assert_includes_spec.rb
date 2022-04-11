# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts assert_includes' do
  let(:rewriter_name) { 'minitest/assert_includes' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert(collection.include?(object))
  EOS

  let(:test_rewritten_content) { <<~EOS }
    assert_includes(collection, object)
  EOS

  include_examples 'convertable'
end
