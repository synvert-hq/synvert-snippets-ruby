require 'spec_helper'

RSpec.describe 'RSpec converts pending to skip' do
  let(:rewriter_name) { 'rspec/pending_to_skip' }
  let(:fake_file_path) { 'spec/models/post_spec.rb' }
  let(:test_content) { "
describe 'example' do
  it 'is skipped', :pending => true do
    do_something_possibly_fail
  end

  pending 'is skipped' do
    do_something_possibly_fail
  end

  it 'is skipped' do
    pending
    do_something_possibly_fail
  end

  it 'is run and expected to fail' do
    pending do
      do_something_surely_fail
    end
  end
end
  "}
  let(:test_rewritten_content) { "
describe 'example' do
  it 'is skipped', :skip => true do
    do_something_possibly_fail
  end

  skip 'is skipped' do
    do_something_possibly_fail
  end

  it 'is skipped' do
    skip
    do_something_possibly_fail
  end

  it 'is run and expected to fail' do
    skip
    do_something_surely_fail
  end
end
  "}

  include_examples 'convertable'
end
