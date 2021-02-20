# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert controller filter to action' do
  let(:rewriter_name) { 'rails/convert_controller_filter_to_action' }
  let(:fake_file_path) { 'app/controllers/posts_controller.rb' }
  let(:test_content) {
    '
class PostsController < ApplicationController
  skip_filter :authorize
  before_filter :load_post
  after_filter :track_post
  around_filter :log_post
end
  '
  }
  let(:test_rewritten_content) {
    '
class PostsController < ApplicationController
  skip_action_callback :authorize
  before_action :load_post
  after_action :track_post
  around_action :log_post
end
  '
  }

  include_examples 'convertable'
end
