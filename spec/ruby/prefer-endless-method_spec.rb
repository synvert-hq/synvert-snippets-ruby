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

  context 'heredoc' do
    let(:test_content) { <<~EOS }
      def sample_gemfile_lock_content
        <<~GEMFILE_LOCK
          GEM
            remote: https://rubygems.org/
        GEMFILE_LOCK
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      def sample_gemfile_lock_content = <<~GEMFILE_LOCK
        GEM
          remote: https://rubygems.org/
      GEMFILE_LOCK
    EOS

    include_examples 'convertable'
  end

  context 'def inside class' do
    let(:test_content) { <<~EOS }
      class User
        def generate_invitation_token
          loop do
            token = SecureRandom.hex(10)
            unless Membership.exists?(invitation_token: token)
              self.invitation_token = token
              break
            end
          end
        end
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      class User
        def generate_invitation_token = loop do
          token = SecureRandom.hex(10)
          unless Membership.exists?(invitation_token: token)
            self.invitation_token = token
            break
          end
        end
      end
    EOS

    include_examples 'convertable'
  end
end
