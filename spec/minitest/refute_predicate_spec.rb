# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts refute_predicate' do
  let(:rewriter_name) { 'minitest/refute_predicate' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert(!expected.zero?)
    refute(expected.zero?)
  EOS

  let(:test_rewritten_content) { <<~EOS }
    refute_predicate(expected, :zero?)
    refute_predicate(expected, :zero?)
  EOS

  include_examples 'convertable'
end