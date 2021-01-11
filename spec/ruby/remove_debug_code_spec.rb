require 'spec_helper'

RSpec.describe 'Ruby removes debug code' do
  let(:rewriter_name) { 'ruby/remove_debug_code' }
  let(:test_content) { "
def test
  puts 'hello world'
  p 'debug'
end
  "}
  let(:test_rewritten_content) { "
def test
end
  "}

  include_examples 'convertable'
end
