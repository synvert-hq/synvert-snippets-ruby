require 'spec_helper'

RSpec.describe 'RSpec converts boolean matcher' do
  let(:rewriter_name) { 'rspec/boolean_matcher' }
  let(:fake_file_path) { 'spec/models/post_spec.rb' }
  let(:test_content) { "
describe Post do
  it 'case' do
    expect(obj).to be_true
    expect(obj).to be_false
  end
end
  "}
  let(:test_rewritten_content) { "
describe Post do
  it 'case' do
    expect(obj).to be_truthy
    expect(obj).to be_falsey
  end
end
  "}

  include_examples 'convertable'
end
