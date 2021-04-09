# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'RSpec converts be_close to be_within' do
  let(:rewriter_name) { 'rspec/be_close_to_be_within' }
  let(:fake_file_path) { 'spec/models/post_spec.rb' }
  let(:test_content) { <<~EOS }
    describe Post do
      it 'test' do
        expect(1.0 / 3.0).to be_close(0.333, 0.001)
      end
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    describe Post do
      it 'test' do
        expect(1.0 / 3.0).to be_within(0.001).of(0.333)
      end
    end
  EOS

  include_examples 'convertable'
end
