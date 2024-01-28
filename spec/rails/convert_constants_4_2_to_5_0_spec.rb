# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails constants from 4.2 to 5.0' do
  let(:rewriter_name) { 'rails/convert_constants_4_2_to_5_0' }
  let(:fake_file_paths) { 'app/controllers/posts_controller.rb' }
  let(:test_content) { <<~EOS }
    class PostsController < ApplicationController
      def test_load_error
        rescue MissingSourceFile
      end
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    class PostsController < ApplicationController
      def test_load_error
        rescue LoadError
      end
    end
  EOS

  include_examples 'convertable'
end
