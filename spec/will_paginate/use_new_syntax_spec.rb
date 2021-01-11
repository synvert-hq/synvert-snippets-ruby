# encoding: utf-8

require 'spec_helper'

RSpec.describe 'Use will_paginate new syntax' do
  let(:rewriter_name) { 'will_paginate/use_new_syntax' }
  let(:fake_file_path) { 'app/models/post.rb' }
  let(:test_content) { '
class Post
  def queries
    Post.paginate(:conditions => {:active => true}, :order => "created_at DESC", :per_page => 10, :page => 1)
    Post.paginate(:per_page => 10, :page => 1)
    Post.paginate

    Post.paginated_each(:conditions => {:active => true}, :order => "created_at DESC", :per_page => 10) do |post|
    end
    Post.paginated_each(:per_page => 10) do |post|
    end
    Post.paginated_each do |post|
    end
  end
end
  '}
  let(:test_rewritten_content) { '
class Post
  def queries
    Post.where(:active => true).order("created_at DESC").paginate(:per_page => 10, :page => 1)
    Post.paginate(:per_page => 10, :page => 1)
    Post.paginate

    Post.where(:active => true).order("created_at DESC").find_each(:batch_size => 10) do |post|
    end
    Post.find_each(:batch_size => 10) do |post|
    end
    Post.find_each do |post|
    end
  end
end
  '}

  include_examples 'convertable'
end
