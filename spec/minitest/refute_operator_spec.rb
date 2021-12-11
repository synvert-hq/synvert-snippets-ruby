# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts refute_operator' do
  let(:rewriter_name) { 'minitest/refute_operator' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert(!(expected > actual))
    refute(expected > actual)
  EOS

  let(:test_rewritten_content) { <<~EOS }
    refute_operator(expected, :>, actual)
    refute_operator(expected, :>, actual)
  EOS

  include_examples 'convertable'
end