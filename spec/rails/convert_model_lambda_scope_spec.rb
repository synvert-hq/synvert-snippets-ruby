# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert model lambda scope' do
  let(:rewriter_name) { 'rails/convert_model_lambda_scope' }
  let(:fake_file_path) { 'app/models/post.rb' }
  let(:test_content) { '
class Post < ActiveRecord::Base
  scope :active, where(active: true)
  scope :published, Proc.new { where(published: true) }
  scope :by_user, proc { |user_id| where(user_id: user_id) }

  default_scope order("updated_at DESC")
  default_scope { order("created_at DESC") }
end
  '}
  let(:test_rewritten_content) { '
class Post < ActiveRecord::Base
  scope :active, -> { where(active: true) }
  scope :published, -> { where(published: true) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  default_scope -> { order("updated_at DESC") }
  default_scope -> { order("created_at DESC") }
end
  '}

  include_examples 'convertable'
end
