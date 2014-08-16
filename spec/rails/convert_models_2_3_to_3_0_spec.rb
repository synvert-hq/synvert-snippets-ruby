# encoding: utf-8

require 'spec_helper'

describe 'Convert rails models from 2.3 to 3.0' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/convert_models_2_3_to_3_0.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:post_content) {'''
class Post
  named_scope :active, :conditions => {:active => true}, :order => "created_at desc"
  named_scope :my_active, lambda { |user| {:conditions => ["user_id = ? and active = ?", user.id, true], :order => "created_at desc"} }
  default_scope :order => "id DESC"

  def queries
    Post.find(:all, :limit => 2)
    Post.find(:all)
    Post.find(:first)
    Post.first(:conditions => {:title => "test"})
    Post.all(:joins => :comments)

    with_scope(:find => {:conditions => {:active => true}}) { Post.first }
    with_exclusive_scope(:find => {:limit =>1}) { Post.last }

    Client.count("age", :conditions => {:active => true})
    Client.average("orders_count", :conditions => {:active => true})
    Client.min("age", :conditions => {:active => true})
    Client.max("age", :conditions => {:active => true})
    Client.sum("orders_count", :conditions => {:active => true})
  end

  def validate_email
    self.errors.on(:email).present?
  end

  def save_with_validate
    self.save
  end

  def save_without_validate
    self.save(false)
  end
end
    '''}
    let(:post_rewritten_content) {'''
class Post
  scope :active, where(:active => true).order("created_at desc")
  scope :my_active, lambda { |user| where("user_id = ? and active = ?", user.id, true).order("created_at desc") }
  default_scope order("id DESC")

  def queries
    Post.limit(2)
    Post.all
    Post.first
    Post.where(:title => "test").first
    Post.joins(:comments)

    with_scope(where(:active => true)) { Post.first }
    with_exclusive_scope(limit(1)) { Post.last }

    Client.where(:active => true).count("age")
    Client.where(:active => true).average("orders_count")
    Client.where(:active => true).min("age")
    Client.where(:active => true).max("age")
    Client.where(:active => true).sum("orders_count")
  end

  def validate_email
    self.errors[:email].present?
  end

  def save_with_validate
    self.save
  end

  def save_without_validate
    self.save(:validate => false)
  end
end
    '''}

    it 'converts' do
      FileUtils.mkdir_p 'app/models'
      File.write 'app/models/post.rb', post_content
      @rewriter.process
      expect(File.read 'app/models/post.rb').to eq post_rewritten_content
    end
  end
end
