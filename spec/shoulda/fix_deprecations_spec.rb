require 'spec_helper'

RSpec.describe 'Fix shoulda deprecations' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/shoulda/fix_deprecations.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:post_test_content) { "
class PostTest < ActiveSupport::TestCase
  should validate_format_of(:email).with('user@example.com')

  should ensure_inclusion_of(:age).in_range(0..100)

  should ensure_exclusion_of(:age).in_range(30..60)
end
    "}
    let(:post_test_rewritten_content) { "
class PostTest < ActiveSupport::TestCase
  should allow_value('user@example.com').for(:email)

  should validate_inclusion_of(:age).in_range(0..100)

  should validate_exclusion_of(:age).in_range(30..60)
end
    "}
    let(:posts_controller_test_content) { '
class UsersControllerTest < ActionController::TestCase
  context "GET /show" do
    should assign_to(:user)
    should assign_to(:user) { @user }
    should_not assign_to(:user)
    should_not assign_to(:user) { @user }

    should respond_with_content_type "application/json"
  end
end
    '}
    let(:posts_controller_test_rewritten_content) { '
class UsersControllerTest < ActionController::TestCase
  context "GET /show" do
    should "assigns user" do
      assert_not_nil assigns(:user)
    end
    should "assigns user" do
      assert_equal @user, assigns(:user)
    end
    should "no assigns user" do
      assert_nil assigns(:user)
    end
    should "no assigns user" do
      assert_not_equal @user, assigns(:user)
    end

    should "responds with application/json" do
      assert_equal "application/json", response.content_type
    end
  end
end
    '}

    it 'converts' do
      FileUtils.mkdir_p 'test/unit'
      FileUtils.mkdir_p 'test/functional'
      File.write 'test/unit/post_test.rb', post_test_content
      File.write 'test/functional/posts_controller_test.rb', posts_controller_test_content
      @rewriter.process
      expect(File.read 'test/unit/post_test.rb').to eq post_test_rewritten_content
      expect(File.read 'test/functional/posts_controller_test.rb').to eq posts_controller_test_rewritten_content
    end
  end
end
