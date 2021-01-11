require 'spec_helper'

RSpec.describe 'RSpec converts should to expect' do
  let(:rewriter_name) { 'rspec/should_to_expect' }
  let(:fake_file_path) { 'spec/models/post_spec.rb' }
  let(:test_content) { "
describe Post do
  it 'test' do
    obj.should matcher
    obj.should_not matcher

    1.should == 1
    1.should < 2
    Integer.should === 1
    'string'.should =~ /^str/
    [1, 2, 3].should =~ [2, 1, 3]
  end
end
  "}
  let(:test_rewritten_content) { "
describe Post do
  it 'test' do
    expect(obj).to matcher
    expect(obj).not_to matcher

    expect(1).to eq 1
    expect(1).to be < 2
    expect(Integer).to be === 1
    expect('string').to match /^str/
    expect([1, 2, 3]).to match_array [2, 1, 3]
  end
end
  "}

  include_examples 'convertable'
end
