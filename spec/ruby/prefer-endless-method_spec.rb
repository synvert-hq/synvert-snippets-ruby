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

  context 'do not process if end_keyword is nil' do
    let(:test_content) { <<~EOS }
      def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      end
    EOS

    include_examples 'convertable'
  end

  context 'do not process for multi_write_node' do
    let(:test_content) { <<~EOS }
      def index
        @pagy, @builds = pagy(@organization.builds)
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      def index
        @pagy, @builds = pagy(@organization.builds)
      end
    EOS

    include_examples 'convertable'
  end

  context 'do not process for or_node' do
    let(:test_content) { <<~EOS }
      def new_rating(old_rating)
        NEW_TO_OLD_MAPPER[old_rating] or raise "Unknown new rating"
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      def new_rating(old_rating)
        NEW_TO_OLD_MAPPER[old_rating] or raise "Unknown new rating"
      end
    EOS

    include_examples 'convertable'
  end

  context 'do not process for hash_node' do
    let(:test_content) { <<~EOS }
      def query
        { foo: 'bar' }
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      def query
        { foo: 'bar' }
      end
    EOS

    include_examples 'convertable'
  end

  context 'do not process for call_node without parentheses' do
    let(:test_content) { <<~EOS }
      def should_be_ignored
        should 'be ignored' do
        end
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      def should_be_ignored
        should 'be ignored' do
        end
      end
    EOS

    include_examples 'convertable'
  end

  context 'do not process if name ends with =' do
    let(:test_content) { <<~EOS }
      def remove_item_ids=(item_ids)
        Item.where(id: item_ids).destroy_all
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      def remove_item_ids=(item_ids)
        Item.where(id: item_ids).destroy_all
      end
    EOS

    include_examples 'convertable'
  end

  context 'process for operator method' do
    let(:test_content) { <<~EOS }
      def ==(other)
        true
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      def ==(other) = true
    EOS

    include_examples 'convertable'
  end

  context 'do not process if parameter without parentheses' do
    let(:test_content) { <<~EOS }
      def initialize item
        @item = item
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      def initialize item
        @item = item
      end
    EOS

    include_examples 'convertable'
  end

  context 'class method' do
    let(:test_content) { <<~EOS }
      def self.enqueue(item_id)
        Resque.enqueue(self, item_id:)
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      def self.enqueue(item_id) = Resque.enqueue(self, item_id:)
    EOS

    include_examples 'convertable'
  end

  context 'do not process for endless method' do
    let(:test_content) { <<~EOS }
      class user
        def generate_invitation_token = loop do
          token = securerandom.hex(10)
          unless membership.exists?(invitation_token: token)
            self.invitation_token = token
            break
          end
        end
      end
    EOS
    let(:test_rewritten_content) { <<~EOS }
      class user
        def generate_invitation_token = loop do
          token = securerandom.hex(10)
          unless membership.exists?(invitation_token: token)
            self.invitation_token = token
            break
          end
        end
      end
    EOS

    include_examples 'convertable'
  end
end
