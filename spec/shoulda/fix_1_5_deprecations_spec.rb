# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Fix shoulda 1.5 deprecations' do
  let(:rewriter_name) { 'shoulda/fix_1_5_deprecations' }

  context 'unit test methods' do
    let(:fake_file_path) { 'test/unit/post_test.rb' }
    let(:test_content) {
      "
class PostTest < ActiveSupport::TestCase
  should validate_format_of(:email).with('user@example.com')
end
    "
    }
    let(:test_rewritten_content) {
      "
class PostTest < ActiveSupport::TestCase
  should allow_value('user@example.com').for(:email)
end
    "
    }

    include_examples 'convertable'
  end

  context 'functional test methods' do
    let(:fake_file_path) { 'test/functional/posts_controller_test.rb' }
    let(:test_content) {
      '
class UsersControllerTest < ActionController::TestCase
  context "GET /show" do
    should assign_to(:user)
    should assign_to(:user) { @user }
    should_not assign_to(:user)
    should_not assign_to(:user) { @user }

    should respond_with_content_type "application/json"
  end
end
    '
    }
    let(:test_rewritten_content) {
      '
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
    '
    }

    include_examples 'convertable'
  end
end
