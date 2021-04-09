# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby uses new -> synax' do
  let(:rewriter_name) { 'ruby/new_lambda_syntax' }
  let(:test_content) { <<~EOS }
    lambda { test }
    lambda { |a, b, c| a + b + c }
  EOS

  let(:test_rewritten_content) { <<~EOS }
    -> { test }
    ->(a, b, c) { a + b + c }
  EOS

  include_examples 'convertable'
end
