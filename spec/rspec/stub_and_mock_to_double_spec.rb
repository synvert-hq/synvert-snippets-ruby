require 'spec_helper'

RSpec.describe 'RSpec converts stub and mock to double' do
  let(:rewriter_name) { 'rspec/stub_and_mock_to_double' }
  let(:fake_file_path) { 'spec/models/post_spec.rb' }
  let(:test_content) {
    "
describe Post do
  it 'test' do
    stub('something')
    mock('something')
  end
end
  "
  }
  let(:test_rewritten_content) {
    "
describe Post do
  it 'test' do
    double('something')
    double('something')
  end
end
  "
  }

  include_examples 'convertable'
end
