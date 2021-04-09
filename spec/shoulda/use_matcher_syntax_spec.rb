# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Use shoulda matcher syntax' do
  let(:rewriter_name) { 'shoulda/use_matcher_syntax' }

  context 'unit test methods' do
    let(:fake_file_path) { 'test/unit/post_test.rb' }
    let(:test_content) { <<~EOS }
      class PostTest < ActiveSupport::TestCase
        should_belong_to :user
        should_have_one :category, :location
        should_have_many :comments
        should_have_many :contributors, :through => :comments
        should_have_and_belong_to_many :tags

        should_validate_presence_of :title, :body

        should_validate_uniqueness_of :keyword, :username
        should_validate_uniqueness_of :name, :message => 'O NOES! SOMEONE STOELED YER NAME!'
        should_validate_uniqueness_of :address, :scoped_to => [:first_name, :last_name]
        should_validate_uniqueness_of :email, :case_sensitive => false

        should_validate_numericality_of :age

        should_validate_acceptance_of :eula

        should_ensure_length_in_range :password, (6..20)
        should_ensure_length_at_least :name, 3
        should_ensure_length_is :ssn, 9

        should_ensure_value_in_range :age, (0..100)

        should_allow_values_for :isbn, 'isbn 1 2345 6789 0', 'ISBN 1-2345-6789-0'
        should_not_allow_values_for :isbn, 'bad 1', 'bad 2'

        should_allow_mass_assignment_of :first_name, :last_name
        should_not_allow_mass_assignment_of :password, :admin_flag

        should_have_readonly_attributes :password, :admin_flag
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      class PostTest < ActiveSupport::TestCase
        should belong_to(:user)
        should have_one(:category)
        should have_one(:location)
        should have_many(:comments)
        should have_many(:contributors).through(:comments)
        should have_and_belong_to_many(:tags)

        should validate_presence_of(:title)
        should validate_presence_of(:body)

        should validate_uniqueness_of(:keyword)
        should validate_uniqueness_of(:username)
        should validate_uniqueness_of(:name).with_message('O NOES! SOMEONE STOELED YER NAME!')
        should validate_uniqueness_of(:address).scoped_to([:first_name, :last_name])
        should validate_uniqueness_of(:email).case_insensitive

        should validate_numericality_of(:age)

        should validate_acceptance_of(:eula)

        should ensure_length_of(:password).is_at_least(6).is_at_most(20)
        should ensure_length_of(:name).is_at_least(3)
        should ensure_length_of(:ssn).is_equal_to(9)

        should ensure_inclusion_of(:age).in_range(0..100)

        should allow_value('isbn 1 2345 6789 0').for(:isbn)
        should allow_value('ISBN 1-2345-6789-0').for(:isbn)
        should_not allow_value('bad 1').for(:isbn)
        should_not allow_value('bad 2').for(:isbn)

        should allow_mass_assignment_of(:first_name)
        should allow_mass_assignment_of(:last_name)
        should_not allow_mass_assignment_of(:password)
        should_not allow_mass_assignment_of(:admin_flag)

        should have_readonly_attributes(:password)
        should have_readonly_attributes(:admin_flag)
      end
    EOS

    include_examples 'convertable'
  end

  context 'functional test methods' do
    let(:fake_file_path) { 'test/functional/posts_controller_test.rb' }
    let(:test_content) { <<~EOS }
      class UsersControllerTest < ActionController::TestCase
        should "test" do
          should_set_the_flash_to "Thank you for placing this order."
          should_not_set_the_flash
          should_filter_params :password, :ssn

          should_assign_to :user, :posts
          should_assign_to :user, :class => User
          should_assign_to(:user) { @user }
          should_not_assign_to :user, :posts

          should_respond_with :success
          should_respond_with_content_type :rss

          should_set_session(:user_id) { @user.id }

          should_render_template :new

          should_render_with_layout "special"

          should_render_without_layout

          should_redirect_to("the user profile") { user_url(@user) }

          should_route :get, "/posts", :controller => :posts, :action => :index
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      class UsersControllerTest < ActionController::TestCase
        should "test" do
          should set_the_flash.to("Thank you for placing this order.")
          should_not set_the_flash
          should filter_param(:password)
          should filter_param(:ssn)

          should assign_to(:user)
          should assign_to(:posts)
          should assign_to(:user).with_kind_of(User)
          should assign_to(:user).with(@user)
          should_not assign_to(:user)
          should_not assign_to(:posts)

          should respond_with(:success)
          should respond_with_content_type(:rss)

          should set_session(:user_id).to(@user.id)

          should render_template(:new)

          should render_with_layout("special")

          should_not render_with_layout

          should redirect_to("the user profile") { user_url(@user) }

          should route(:get, "/posts").to(:controller => :posts, :action => :index)
        end
      end
    EOS

    include_examples 'convertable'
  end
end
