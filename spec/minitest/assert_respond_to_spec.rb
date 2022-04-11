# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts assert_respond_to' do
  let(:rewriter_name) { 'minitest/assert_respond_to' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert(object.respond_to?(some_method))
  EOS

  let(:test_rewritten_content) { <<~EOS }
    assert_respond_to(object, some_method)
  EOS

  include_examples 'convertable'
end
