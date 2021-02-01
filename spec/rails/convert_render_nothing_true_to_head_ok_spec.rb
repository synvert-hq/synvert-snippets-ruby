require 'spec_helper'

RSpec.describe 'Convert render nothing: true to head :ok' do
  let(:rewriter_name) { 'rails/convert_render_nothing_true_to_head_ok' }
  let(:fake_file_path) { 'app/controllers/posts_controller.rb' }
  let(:test_content) { '
class PostsController < ApplicationController
  def test
    render nothing: true
  end
end
  '}
  let(:test_rewritten_content) { '
class PostsController < ApplicationController
  def test
    head :ok
  end
end
  '}

  include_examples 'convertable'
end
