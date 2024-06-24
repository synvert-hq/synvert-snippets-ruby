# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Prefer endless method' do
  let(:rewriter_name) { 'ruby/prefer-endless-method' }
  let(:fake_file_path) { 'foobar.rb' }

  context 'expression' do
    let(:test_content) { <<~EOS }
      def one_plus_one
        1 + 1
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      def one_plus_one = 1 + 1
    EOS

    include_examples 'convertable'
  end

  context 'block call' do
    let(:test_content) { <<~EOS }
      def existing_key(device)
        transaction do
          key = device.one_time_keys.order(Arel.sql('random()')).first!
          key.destroy!
        end
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      def existing_key(device) = transaction do
        key = device.one_time_keys.order(Arel.sql('random()')).first!
        key.destroy!
      end
    EOS

    include_examples 'convertable'
  end
end
