# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'RSpec converts block to expect' do
  let(:rewriter_name) { 'rspec/block_to_expect' }
  let(:fake_file_path) { 'spec/models/post_spec.rb' }
  let(:test_content) { "
describe Post do
  it 'test' do
    lambda { do_something }.should raise_error
    proc { do_something }.should raise_error
    -> { do_something }.should raise_error
  end
end
  "}
  let(:test_rewritten_content) { "
describe Post do
  it 'test' do
    expect { do_something }.to raise_error
    expect { do_something }.to raise_error
    expect { do_something }.to raise_error
  end
end
  "}

  include_examples 'convertable'
end
