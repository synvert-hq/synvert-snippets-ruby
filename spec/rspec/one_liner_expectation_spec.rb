# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'RSpec converts one liner expectation' do
  let(:rewriter_name) { 'rspec/one_liner_expectation' }
  let(:fake_file_path) { 'spec/models/post_spec.rb' }
  let(:test_content) { <<~EOS }
    describe Post do
      it { should matcher }
      it { should_not matcher }

      it { should have(3).items }
      it { should have_at_least(3).players }
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    describe Post do
      it { is_expected.to matcher }
      it { is_expected.not_to matcher }

      it 'has 3 items' do
        expect(subject.size).to eq(3)
      end
      it 'has at least 3 players' do
        expect(subject.players.size).to be >= 3
      end
    end
  EOS

  include_examples 'convertable'
end
