require 'spec_helper'

describe 'Convert named_scope to scope' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/convert_named_scope_to_scope.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:post_content) {'''
class Post
  named_scope :active, :conditions => {:active => true}, :order => "created_at desc"
  named_scope :my_active, lambda { |user| {:conditions => ["user_id = ? and active = ?", user.id, true], :order => "created_at desc"} }
end
    '''}
    let(:post_rewritten_content) {'''
class Post
  scope :active, where(:active => true).order("created_at desc")
  scope :my_active, lambda { |user| where("user_id = ? and active = ?", user.id, true).order("created_at desc") }
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
