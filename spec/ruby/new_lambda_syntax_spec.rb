require 'spec_helper'

RSpec.describe 'Ruby uses new -> synax' do
  let(:rewriter_name) { 'ruby/new_lambda_syntax' }
  let(:test_content) {
    '
lambda { test }
lambda { |a, b, c| a + b + c }
  '
  }
  let(:test_rewritten_content) {
    '
-> { test }
->(a, b, c) { a + b + c }
  '
  }

  include_examples 'convertable'
end
