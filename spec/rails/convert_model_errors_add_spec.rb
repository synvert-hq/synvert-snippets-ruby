# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert model errors.add' do
  let(:rewriter_name) { 'rails/convert_model_errors_add' }
  let(:fake_file_path) { 'app/models/post.rb' }
  let(:test_content) { '
class Post < ApplicationRecord
  def validate_author
    errors[:base] = "author not present" unless author
    self.errors[:base] = "author not present" unless author
  end
end
  '}
  let(:test_rewritten_content) { '
class Post < ApplicationRecord
  def validate_author
    errors.add(:base, "author not present") unless author
    self.errors.add(:base, "author not present") unless author
  end
end
  '}

  include_examples 'convertable'
end
