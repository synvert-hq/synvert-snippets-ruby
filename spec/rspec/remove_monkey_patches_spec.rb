require 'spec_helper'

RSpec.describe 'RSpec removes monkey patches' do
  let(:rewriter_name) { 'rspec/remove_monkey_patches' }

  context 'unit test' do
    let(:fake_file_path) { 'spec/models/post_spec.rb' }
    let(:test_content) {
      "
describe Post do
  describe '.active' do
  end
end
    "
    }
    let(:test_rewritten_content) {
      "
RSpec.describe Post do
  describe '.active' do
  end
end
    "
    }

    include_examples 'convertable'
  end

  context 'unit test with RSpec' do
    let(:fake_file_path) { 'spec/models/comment_spec.rb' }
    let(:test_content) {
      "
RSpec.describe Comment do
  describe '.active' do
  end
end
    "
    }
    let(:test_rewritten_content) {
      "
RSpec.describe Comment do
  describe '.active' do
  end
end
    "
    }

    include_examples 'convertable'
  end

  context 'support' do
    let(:fake_file_path) { 'spec/support/post.rb' }
    let(:test_content) {
      "
shared_examples 'shared examples' do
end
    "
    }
    let(:test_rewritten_content) {
      "
RSpec.shared_examples 'shared examples' do
end
    "
    }

    include_examples 'convertable'
  end

  context 'spec_helper' do
    let(:fake_file_path) { 'spec/spec_helper.rb' }
    let(:test_content) {
      '
RSpec.configure do |config|
end
    '
    }
    let(:test_rewritten_content) {
      '
RSpec.configure do |config|
  config.expose_dsl_globally = false
end
    '
    }

    include_examples 'convertable'
  end
end
