# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deprecate errors as hash' do
  let(:rewriter_name) { 'rails/deprecate_errors_as_hash' }
  let(:fake_file_path) { 'app/controllers/posts_controller.rb' }
  let(:test_content) { <<~EOS }
    class PostsController < ApplicationController
      def create
        @post = Post.create(post_params)
        @post.errors[:title] << 'is not interesting enough.'
        render json: { fields: @post.errors.keys, errors: @post.errors.values }
      end
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class PostsController < ApplicationController
      def create
        @post = Post.create(post_params)
        @post.errors.add(:title, 'is not interesting enough.')
        render json: { fields: @post.errors.map(&:attribute), errors: @post.errors.map(&:message) }
      end
    end
  EOS

  include_examples 'convertable'
end
