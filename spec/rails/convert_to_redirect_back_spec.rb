# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert to redirect_back' do
  let(:rewriter_name) { 'rails/convert_to_redirect_back' }
  let(:fake_file_path) { 'app/controllers/posts_controller.rb' }
  let(:test_content) { '
class PostsController < ApplicationController
  def redirect_back
    redirect_to :back
  end
end
  '}
  let(:test_rewritten_content) { '
class PostsController < ApplicationController
  def redirect_back
    redirect_back
  end
end
  '}

  include_examples 'convertable'
end
