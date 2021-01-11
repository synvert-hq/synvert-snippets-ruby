require 'spec_helper'

RSpec.describe 'Ruby .keys.each to .each_key' do
  let(:rewriter_name) { 'ruby/keys_each_to_each_key' }
  let(:test_content) { "
params.keys.each do |param|
end
  "}
  let(:test_rewritten_content) { "
params.each_key do |param|
end
  "}

  include_examples 'convertable'
end
