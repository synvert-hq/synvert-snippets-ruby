# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Prefer endless method' do
  let(:rewriter_name) { 'ruby/prefer-endless-method' }
  let(:fake_file_path) { 'foobar.rb' }
  let(:test_content) { <<~EOS }
    def one_plus_one
      1 + 1
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    def one_plus_one = 1 + 1
  EOS

  include_examples 'convertable'
end
