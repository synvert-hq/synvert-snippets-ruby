require 'spec_helper'

RSpec.describe 'Ruby converts Kernel#open to URI.open' do
  let(:rewriter_name) { 'ruby/kernel_open_to_uri_open' }
  let(:test_content) { "open('http://test.com')" }
  let(:test_rewritten_content) { "URI.open('http://test.com')" }

  include_examples 'convertable'
end
