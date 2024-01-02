# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deprecate calling redis inside Redis#pipelined' do
  let(:rewriter_name) { 'redis/deprecate_calling_redis_inside_pipelined' }
  let(:fake_file_path) { 'app/models/user.rb' }
  let(:test_content) { <<~EOS }
    redis.pipelined do
      redis.get("key")
    end

    redis.pipelined do |pipeline|
      pipeline.get("key")
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    redis.pipelined do |pipeline|
      pipeline.get("key")
    end

    redis.pipelined do |pipeline|
      pipeline.get("key")
    end
  EOS

  include_examples 'convertable'
end
