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

  within_files '{test,spec}/factories/**/*.rb' do
    # add
    # FactoryGirl.define do
    # end
    unless_exist_node type: 'send', receiver: 'FactoryGirl', message: 'define' do
      body = node.to_source.gsub("\n", "\n  ")
      new_body = <<~EOS
        FactoryGirl.define do
          #{body}
        end
      EOS
      replace_with new_body.strip
    end
  end

  within_files '{test,spec}/factories/**/*.rb' do
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
    within_node type: 'block',
                caller: {
                  type: 'send',
                  receiver: 'Factory',
                  message: 'define'
                },
                arguments: {
                  size: 1
                } do
      argument = node.arguments.first.to_source
      with_node type: 'block', caller: { type: 'send', receiver: argument } do
        goto_node :caller do
          delete :receiver, :dot
        end
      end
    end

    # Factory.define :user do |user|
    #   after_create { |instance| create_list(:post, 5, user: instance) }
    # end
    # =>
    # Factory.define :user do |user|
    #   after(:create) { |instance| create_list(:post, 5, user: instance) }
    # end
    %w[after_build after_create].each do |message|
      within_node type: 'block', caller: { type: 'send', message: message } do
        new_message = message.sub('after_', '')
        replace :caller, with: "after(:#{new_message})"
      end
    end
  end

  within_files '{test,spec}/factories/**/*.rb' do
    # Factory.define :user do |user|
    #   user.admin true
    # end
    # =>
    # Factory.define :user do |user|
    #   admin true
    # end
    within_node type: 'block',
                caller: {
                  type: 'send',
                  receiver: 'Factory',
                  message: 'define'
                },
                arguments: {
                  size: 1
                } do
      argument = node.arguments.first.to_source
      with_node type: 'send', receiver: argument do
        delete :receiver, :dot
      end
    end
  end

  within_files '{test,spec}/factories/**/*.rb' do
    # Factory.define :user do |user|
    # end
    # =>
    # factory :user do
    # end
    within_node type: 'block',
                caller: {
                  type: 'send',
                  receiver: 'Factory',
                  message: 'define'
                },
                arguments: {
                  size: 1
                } do
      delete :arguments, :pipes
      goto_node :caller do
        delete :receiver, :dot
        replace :message, with: 'factory'
      end
    end

    # Factory.sequence :login do |n|
    #   "new_user_#{n}"
    # end
    # =>
    # sequence :login do |n|
    #   "new_user_#{n}"
    # end
    within_node type: 'block',
                caller: {
                  type: 'send',
                  receiver: 'Factory',
                  message: 'sequence'
                },
                arguments: {
                  size: 1
                } do
      goto_node :caller do
        delete :receiver, :dot
      end
    end
  end

  within_files '{test,spec}/**/*.rb' do
    # Factory(:user) => create(:user)
    with_node type: 'send', receiver: nil, message: 'Factory' do
      replace :message, with: 'create'
    end

    # Factory.next(:email) => generate(:email)
    with_node type: 'send', receiver: 'Factory', message: 'next' do
      delete :receiver, :dot
      replace :message, with: 'generate'
    end

    # Factory.stub(:comment) => build_stubbed(:comment)
    with_node type: 'send', receiver: 'Factory', message: 'stub' do
      delete :receiver, :dot
      replace :message, with: 'build_stubbed'
    end

    # Factory.create(:user) => create(:user)
    # Factory.build(:use) => build(:user)
    # Factory.attributes_for(:user) => attributes_for(:user)
    %w[create build attributes_for].each do |message|
      with_node type: 'send', receiver: 'Factory', message: message do
        delete :receiver, :dot
      end
    end
  end
end
