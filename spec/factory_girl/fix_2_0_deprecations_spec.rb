# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Fix factory_girl deprecations' do
  let(:rewriter_name) { 'factory_girl/fix_2_0_deprecations' }

  context 'factory methods' do
    let(:fake_file_path) { 'test/factories/post.rb' }
    let(:test_content) {
      '
Factory.sequence :login do |n|
  "new_user_#{n}"
end

Factory.define(:admin, :parent => :user) do |admin|
  admin.login { Factory.next(:login) }
  admin.admin true
  admin.sequence(:email) {|n| "admin#{n}@test.com" }

  after_create { |instance| create_list(:post, 5, user: instance) }
  after_build do |user|
    user.phone_digits = generate(:phone_digits)
  end
end
    '
    }
    let(:test_rewritten_content) {
      '
FactoryGirl.define do
  sequence :login do |n|
    "new_user_#{n}"
  end

  factory :admin, :parent => :user do
    login { generate(:login) }
    admin true
    sequence(:email) {|n| "admin#{n}@test.com" }

    after(:create) { |instance| create_list(:post, 5, user: instance) }
    after(:build) do |user|
      user.phone_digits = generate(:phone_digits)
    end
  end
end
    '
    }

    include_examples 'convertable'
  end

  context 'unit test methods' do
    let(:fake_file_path) { 'test/unit/post_test.rb' }
    let(:test_content) {
      '
class PostTest < ActiveSupport::TestCase
  def test_post
    Factory(:comment)
    Factory.create(:comment)
    Factory.next(:email)
    Factory.stub(:article)
    Factory.build(:author)
    Factory.attributes_for(:post)
  end
end
    '
    }
    let(:test_rewritten_content) {
      '
class PostTest < ActiveSupport::TestCase
  def test_post
    create(:comment)
    create(:comment)
    generate(:email)
    build_stubbed(:article)
    build(:author)
    attributes_for(:post)
  end
end
    '
    }

    include_examples 'convertable'
  end
end
