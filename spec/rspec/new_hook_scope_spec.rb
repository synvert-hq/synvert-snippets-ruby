# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'RSpec uses new hook scope' do
  let(:rewriter_name) { 'rspec/new_hook_scope' }

  context 'unit test' do
    let(:fake_file_path) { 'spec/models/post_spec.rb' }
    let(:test_content) { <<~EOS }
      describe 'example' do
        before { do_something }
        before(:each) { do_something }
        before(:all) { do_something }
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      describe 'example' do
        before { do_something }
        before(:example) { do_something }
        before(:context) { do_something }
      end
    EOS

    include_examples 'convertable'
  end

  context 'spec_helper' do
    let(:fake_file_path) { 'spec/spec_helper.rb' }
    let(:test_content) { <<~EOS }
      RSpec.configure do |config|
        config.before(:suite) { do_something }
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      RSpec.configure do |config|
        config.before(:suite) { do_something }
      end
    EOS

    include_examples 'convertable'
  end
end
