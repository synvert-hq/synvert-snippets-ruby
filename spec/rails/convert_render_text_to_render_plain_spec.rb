# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert render :text to render :plain' do
  let(:rewriter_name) { 'rails/convert_render_text_to_render_plain' }
  let(:fake_file_path) { 'app/controllers/posts_controller.rb' }
  let(:test_content) { <<~EOS }
      class PostsController < ApplicationController
        def foo
          render text: 'OK'
        end

        def bar
          render text: 'Not OK', status: 403
        end
      end
  EOS
  let(:test_rewritten_content) { <<~EOS }
      class PostsController < ApplicationController
        def foo
          render plain: 'OK'
        end

        def bar
          render plain: 'Not OK', status: 403
        end
      end
  EOS

  include_examples 'convertable'
end
