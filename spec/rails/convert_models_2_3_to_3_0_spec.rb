# encoding: utf-8

require 'spec_helper'

RSpec.describe 'Convert rails models from 2.3 to 3.0' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/convert_models_2_3_to_3_0.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:post_content) { '
class Post
  named_scope :active, :conditions => {:active => true}, :order => "created_at desc"
  named_scope :my_active, lambda { |user| {:conditions => ["user_id = ? and active = ?", user.id, true], :order => "created_at desc"} }
  default_scope :order => "id DESC"

  def queries
    Post.find(:all, :limit => 2)
    Post.find(:all)
    Post.find(:first)
    Post.find(:last, :conditions => {:title => "test"})
    Post.first(:conditions => {:title => "test"})
    Post.all(:joins => :comments)

    Post.find_each(:conditions => {:title => "test"}, :batch_size => 100) do |post|
    end
    Post.find_each(:conditions => {:title => "test"}) do |post|
    end

    Post.find_in_batches(:conditions => {:title => "test"}, :batch_size => 100) do |posts|
    end
    Post.find_in_batches(:conditions => {:title => "test"}) do |posts|
    end

    with_scope(:find => {:conditions => {:active => true}}) { Post.first }
    with_exclusive_scope(:find => {:limit =>1}) { Post.last }

    Client.count("age", :conditions => {:active => true})
    Client.average("orders_count", :conditions => {:active => true})
    Client.min("age", :conditions => {:active => true})
    Client.max("age", :conditions => {:active => true})
    Client.sum("orders_count", :conditions => {:active => true})

    Post.update_all({:title => "title"}, {:title => "test"})
    Post.update_all("title = \'title\'", "title = \'test\'")
    Post.update_all("title = \'title\'", ["title = ?", title])
    Post.update_all({:title => "title"}, {:title => "test"}, {:limit => 2})

    Post.delete_all("title = \'test\'")
    Post.delete_all(["title = ?", title])

    Post.destroy_all("title = \'test\'")
    Post.destroy_all(["title = ?", title])
  end

  def validate_email
    self.errors.add_to_base("error message")
    self.errors.on(:email).present?
  end

  def save_with_validate
    self.save
  end

  def save_without_validate
    self.save(false)
  end
end
    '}
    let(:post_rewritten_content) { '
class Post
  scope :active, where(:active => true).order("created_at desc")
  scope :my_active, lambda { |user| where("user_id = ? and active = ?", user.id, true).order("created_at desc") }
  default_scope order("id DESC")

  def queries
    Post.limit(2)
    Post.all
    Post.first
    Post.where(:title => "test").last
    Post.where(:title => "test").first
    Post.joins(:comments)

    Post.where(:title => "test").find_each(:batch_size => 100) do |post|
    end
    Post.where(:title => "test").find_each do |post|
    end

    Post.where(:title => "test").find_in_batches(:batch_size => 100) do |posts|
    end
    Post.where(:title => "test").find_in_batches do |posts|
    end

    with_scope(where(:active => true)) { Post.first }
    with_exclusive_scope(limit(1)) { Post.last }

    Client.where(:active => true).count("age")
    Client.where(:active => true).average("orders_count")
    Client.where(:active => true).min("age")
    Client.where(:active => true).max("age")
    Client.where(:active => true).sum("orders_count")

    Post.where(:title => "test").update_all(:title => "title")
    Post.where("title = \'test\'").update_all("title = \'title\'")
    Post.where("title = ?", title).update_all("title = \'title\'")
    Post.where(:title => "test").limit(2).update_all(:title => "title")

    Post.where("title = \'test\'").delete_all
    Post.where("title = ?", title).delete_all

    Post.where("title = \'test\'").destroy_all
    Post.where("title = ?", title).destroy_all
  end

  def validate_email
    self.errors.add(:base, "error message")
    self.errors[:email].present?
  end

  def save_with_validate
    self.save
  end

  def save_without_validate
    self.save(:validate => false)
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
