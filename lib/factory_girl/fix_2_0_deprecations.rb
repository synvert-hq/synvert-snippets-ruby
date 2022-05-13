# frozen_string_literal: true

Synvert::Rewriter.new 'factory_girl', 'fix_2_0_deprecations' do
  description <<~EOS
    It fixes factory girl 2.0 deprecations

    ```ruby
    Factory.sequence :login do |n|
      "new_user_\#{n}"
    end
    Factory.define :user do |user|
      user.admin true
      user.login { Factory.next(:login) }
      user.sequence(:email) { |n| "user\#{n}@gmail.com" }
      user.after_create { |instance| create_list(:post, 5, user: instance) }
    end
    ```

    =>

    ```ruby
    FactoryGirl.define do
      sequence :user do |n|
        "new_user_\#{n}"
      end
      factory :user do |user|
        admin true
        login { generate(:login) }
        sequence(:email) { |n| "user\#{n}@gmail.com" }
        after(:create) { |instance| create_list(:post, 5, user: instance) }
      end
    end
    ```

    ```ruby
    Factory(:user)
    Factory.next(:email)
    Factory.stub(:comment)
    Factory.create(:user)
    Factory.build(:use)
    Factory.attributes_for(:user)
    ```

    =>

    ```ruby
    create(:user)
    generate(:email)
    build_stubbed(:comment)
    create(:user)
    build(:user)
    attributes_for(:user)
    ```
  EOS

  if_gem 'factory_girl', '>= 2.0'

  within_files Synvert::RAILS_FACTORY_FILES do
    # add
    # FactoryGirl.define do
    # end
    find_node ':not_has(.send[receiver=FactoryGirl][message=define])' do
      body = node.to_source.gsub("\n", "\n  ")
      new_body = <<~EOS
        FactoryGirl.define do
          #{body}
        end
      EOS
      replace_with new_body.strip
    end
  end

  within_files Synvert::RAILS_FACTORY_FILES do
    # Factory.define :user do |user|
    #   user.login { Factory.next(:login) }
    #   user.sequence(:email) { |n| "user#{n}@gmail.com" }
    #   user.after_create { |instance| create_list(:post, 5, user: instance) }
    # end
    # =>
    # Factory.define :user do |user|
    #   login { Factory.next(:login) }
    #   sequence(:email) { |n| "user#{n}@gmail.com" }
    #   after_create { |instance| create_list(:post, 5, user: instance) }
    # end
    find_node '.block[caller=.send[receiver=Factory][message=define]][arguments.size=1]' do
      argument = node.arguments.first.to_source
      with_node type: 'block', caller: { type: 'send', receiver: argument } do
        delete 'caller.receiver', 'caller.dot'
      end
    end

    # Factory.define :user do |user|
    #   after_create { |instance| create_list(:post, 5, user: instance) }
    # end
    # =>
    # Factory.define :user do |user|
    #   after(:create) { |instance| create_list(:post, 5, user: instance) }
    # end
    find_node '.block[caller=.send[message IN (after_build after_create)]]' do
      new_message = node.caller.message.to_s.sub('after_', '')
      replace :caller, with: "after(:#{new_message})"
    end
  end

  within_files Synvert::RAILS_FACTORY_FILES do
    # Factory.define :user do |user|
    #   user.admin true
    # end
    # =>
    # Factory.define :user do |user|
    #   admin true
    # end
    find_node '.block[caller=.send[receiver=Factory][message=define]][arguments.size=1]' do
      find_node ".send[receiver=#{node.arguments.first.to_source}]" do
        delete :receiver, :dot
      end
    end
  end

  within_files Synvert::RAILS_FACTORY_FILES do
    # Factory.define :user do |user|
    # end
    # =>
    # factory :user do
    # end
    find_node '.block[caller=.send[receiver=Factory][message=define]][arguments.size=1]' do
      delete :arguments, :pipes
      delete 'caller.receiver', 'caller.dot'
      replace 'caller.message', with: 'factory'
    end

    # Factory.sequence :login do |n|
    #   "new_user_#{n}"
    # end
    # =>
    # sequence :login do |n|
    #   "new_user_#{n}"
    # end
    find_node '.block[caller=.send[receiver=Factory][message=sequence]][arguments.size=1]' do
      delete 'caller.receiver', 'caller.dot'
    end
  end

  within_files Synvert::RAILS_TEST_FILES do
    # Factory(:user) => create(:user)
    find_node '.send[receiver=nil][message=Factory]' do
      replace :message, with: 'create'
    end

    # Factory.next(:email) => generate(:email)
    find_node '.send[receiver=Factory][message=next]' do
      delete :receiver, :dot
      replace :message, with: 'generate'
    end

    # Factory.stub(:comment) => build_stubbed(:comment)
    find_node '.send[receiver=Factory][message=stub]' do
      delete :receiver, :dot
      replace :message, with: 'build_stubbed'
    end

    # Factory.create(:user) => create(:user)
    # Factory.build(:use) => build(:user)
    # Factory.attributes_for(:user) => attributes_for(:user)
    find_node '.send[receiver=Factory][message IN (create build attributes_for)]' do
      delete :receiver, :dot
    end
  end
end
