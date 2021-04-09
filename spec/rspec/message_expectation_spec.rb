# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'RSpec converts message expectation' do
  let(:rewriter_name) { 'rspec/message_expectation' }
  let(:fake_file_path) { 'spec/models/post_spec.rb' }
  let(:test_content) { <<~EOS }
    describe Post do
      it 'test' do
        obj.should_receive(:message)
        Klass.any_instance.should_receive(:message)
        obj.should_not_receive(:message)
        Klass.any_instance.should_not_receive(:message)

        expect(obj).to receive(:message).and_return { 1 }

        expect(obj).to receive(:message).and_return
      end
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    describe Post do
      it 'test' do
        expect(obj).to receive(:message)
        expect_any_instance_of(Klass).to receive(:message)
        expect(obj).not_to receive(:message)
        expect_any_instance_of(Klass).not_to receive(:message)

        expect(obj).to receive(:message) { 1 }

        expect(obj).to receive(:message)
      end
    end
  EOS

  include_examples 'convertable'
end
