require 'spec_helper'

RSpec.describe 'Fix factory_girl deprecations' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/factory_girl/fix_deprecations.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:user_factory_content) {'
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
    '}
    let(:user_factory_rewritten_content) {'
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
    '}
    let(:post_test_content) {"
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
    "}
    let(:post_test_rewritten_content) {"
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
    "}

    it 'converts' do
      FileUtils.mkdir_p 'test/factories'
      FileUtils.mkdir_p 'test/unit'
      File.write 'test/factories/user.rb', user_factory_content
      File.write 'test/unit/post_test.rb', post_test_content
      @rewriter.process
      expect(File.read 'test/factories/user.rb').to eq user_factory_rewritten_content
      expect(File.read 'test/unit/post_test.rb').to eq post_test_rewritten_content
    end
  end
end
