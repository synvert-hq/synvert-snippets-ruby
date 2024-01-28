# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deprecate MissingSourceFile' do
  let(:rewriter_name) { 'rails/deprecate_missing_source_file' }
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
