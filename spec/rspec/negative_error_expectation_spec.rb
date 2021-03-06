# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'RSpec converts negative error expectation' do
  let(:rewriter_name) { 'rspec/negative_error_expectation' }
  let(:fake_file_path) { 'spec/models/post_spec.rb' }
  let(:test_content) {
    "
describe Post do
  it 'test' do
    expect { do_something }.not_to raise_error(SomeErrorClass)
    expect { do_something }.not_to raise_error('message')
    expect { do_something }.not_to raise_error(SomeErrorClass, 'message')
  end
end
  "
  }
  let(:test_rewritten_content) {
    "
describe Post do
  it 'test' do
    expect { do_something }.not_to raise_error
    expect { do_something }.not_to raise_error
    expect { do_something }.not_to raise_error
  end
end
  "
  }

  include_examples 'convertable'
end
