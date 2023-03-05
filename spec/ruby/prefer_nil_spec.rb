# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby prefer nil?' do
  let(:rewriter_name) { 'ruby/prefer_nil' }
  let(:fake_file_path) { 'foobar.rb' }
  let(:test_content) { <<~EOS }
    def test
      value1 == nil
      value2 != nil
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    def test
      value1.nil?
      !value2.nil?
    end
  EOS

  include_examples 'convertable'
end
