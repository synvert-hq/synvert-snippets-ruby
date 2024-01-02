# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deprecate calling redis inside Redis#multi' do
  let(:rewriter_name) { 'redis/deprecate_calling_redis_inside_multi' }
  let(:fake_file_path) { 'app/models/user.rb' }
  let(:test_content) { <<~EOS }
    redis.multi do
      redis.get("key")
    end

    redis.multi do |transaction|
      transaction.get("key")
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    redis.multi do |transaction|
      transaction.get("key")
    end

    redis.multi do |transaction|
      transaction.get("key")
    end
  EOS

  include_examples 'convertable'
end
