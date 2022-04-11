# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts refute_path_exists' do
  let(:rewriter_name) { 'minitest/refute_path_exists' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    assert(!File.exist?(path))
    refute(File.exist?(path))
  EOS

  let(:test_rewritten_content) { <<~EOS }
    refute_path_exists(path)
    refute_path_exists(path)
  EOS

  include_examples 'convertable'
end
