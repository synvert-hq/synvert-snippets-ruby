# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts assert_silent' do
  let(:rewriter_name) { 'minitest/assert_silent' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert_output('', '') { puts object.do_something }
  EOS

  let(:test_rewritten_content) { <<~EOS }
    assert_silent { puts object.do_something }
  EOS

  include_examples 'convertable'
end
