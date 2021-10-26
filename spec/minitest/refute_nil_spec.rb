# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts refute_nil' do
  let(:rewriter_name) { 'minitest/refute_nil' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert(!actual.nil?)
    refute(actual.nil?)
  EOS

  let(:test_rewritten_content) { <<~EOS }
    refute_nil(actual)
    refute_nil(actual)
  EOS

  include_examples 'convertable'
end