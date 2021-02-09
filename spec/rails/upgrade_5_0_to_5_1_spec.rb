require 'spec_helper'

RSpec.describe 'Upgrade rails from 5.0 to 5.1' do
  let(:rewriter_name) { 'rails/upgrade_5_0_to_5_1' }
  let(:post_model_content) {
    '
class Post < ApplicationRecord
  def configs
    rgb = HashWithIndifferentAccess.new
    rgb[:black] = "#000000"
    rgb = ActiveSupport::HashWithIndifferentAccess.new
    rgb[:white] = "#FFFFFF"

    Rails.application.config.secrets[:smtp_settings]["address"]
  end
end
  '
  }
  let(:post_model_rewritten_content) {
    '
class Post < ApplicationRecord
  def configs
    rgb = ActiveSupport::HashWithIndifferentAccess.new
    rgb[:black] = "#000000"
    rgb = ActiveSupport::HashWithIndifferentAccess.new
    rgb[:white] = "#FFFFFF"

    Rails.application.config.secrets[:smtp_settings][:address]
  end
end
  '
  }
  let(:fake_file_paths) { ['app/models/post.rb'] }
  let(:test_contents) { [post_model_content] }
  let(:test_rewritten_contents) { [post_model_rewritten_content] }

  include_examples 'convertable with multiple files'
end
