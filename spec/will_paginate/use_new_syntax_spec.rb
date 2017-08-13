# encoding: utf-8
require 'spec_helper'

RSpec.describe 'Use will_paginate new syntax' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/will_paginate/use_new_syntax.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:post_content) { '
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
    let(:post_rewritten_content) { '
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

    it 'converts' do
      FileUtils.mkdir_p 'app/models'
      File.write 'app/models/post.rb', post_content
      @rewriter.process
      expect(File.read 'app/models/post.rb').to eq post_rewritten_content
    end
  end
end
