# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert head response' do
  let(:rewriter_name) { 'rails/convert_head_response' }
  let(:fake_file_path) { 'app/controllers/posts_controller.rb' }
  let(:test_content) {
    '
class PostsController < ApplicationController
  rescue_from BadGateway do
    head status: 502
  end

  def ok
    render nothing: true
  end

  def created
    render nothing: true, status: :created
  end

  def redirect
    head location: "/foo"
  end
end
  '
  }
  let(:test_rewritten_content) {
    '
class PostsController < ApplicationController
  rescue_from BadGateway do
    head 502
  end

  def ok
    head :ok
  end

  def created
    head :created
  end

  def redirect
    head :ok, location: "/foo"
  end
end
  '
  }

  include_examples 'convertable'
end
