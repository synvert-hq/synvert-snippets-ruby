# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'New enum syntax' do
  let(:rewriter_name) { 'rails/new_enum_syntax' }
  let(:fake_file_path) { 'app/models/post.rb' }
  let(:test_content) { <<~EOS }
    class Post < ActiveRecord::Base
      enum status: [ :draft, :published, :archived ], _prefix: true, _scopes: false
      enum category: [ :free, :premium ], _suffix: true, _default: :free

      enum :status, { draft: 0, published: 1, archived: 2 }, prefix: true, scopes: false
      enum :category, { free: 0, premium: 1 }, suffix: true, default: :free
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class Post < ActiveRecord::Base
      enum :status, [ :draft, :published, :archived ], prefix: true, scopes: false
      enum :category, [ :free, :premium ], suffix: true, default: :free

      enum :status, { draft: 0, published: 1, archived: 2 }, prefix: true, scopes: false
      enum :category, { free: 0, premium: 1 }, suffix: true, default: :free
    end
  EOS

  include_examples 'convertable'
end
