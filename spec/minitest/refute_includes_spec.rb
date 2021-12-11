# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts refute_includes' do
  let(:rewriter_name) { 'minitest/refute_includes' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    refute(collection.include?(object))
    assert(!collection.include?(object))
  EOS

  let(:test_rewritten_content) { <<~EOS }
    refute_includes(collection, object)
    refute_includes(collection, object)
  EOS

  include_examples 'convertable'
end