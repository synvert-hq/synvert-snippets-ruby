# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts refute_kind_of' do
  let(:rewriter_name) { 'minitest/refute_kind_of' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert(!'rubocop-minitest'.kind_of?(String))
    refute('rubocop-minitest'.kind_of?(String))
  EOS

  let(:test_rewritten_content) { <<~EOS }
    refute_kind_of(String, 'rubocop-minitest')
    refute_kind_of(String, 'rubocop-minitest')
  EOS

  include_examples 'convertable'
end