# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert to params.expect' do
  let(:rewriter_name) { 'rails/convert_to_params_expect' }
  let(:fake_file_path) { 'app/controllers/posts_controller.rb' }
  let(:test_content) { <<~EOS }
    class PostsController < ApplicationController
      def post_params
        params.require(:post).permit(:title, :summary)
      end

      def post_params
        params.require(:post).permit(:title, :summary, categories: [:name])
      end
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    class PostsController < ApplicationController
      def post_params
        params.expect(post: [:title, :summary])
      end

      def post_params
        params.expect(post: [:title, :summary, categories: [[:name]]])
      end
    end
  EOS

  include_examples 'convertable'
end
