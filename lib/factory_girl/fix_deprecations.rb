# frozen_string_literal: true

Synvert::Rewriter.new 'factory_girl', 'fix_deprecations' do
  description <<-EOF
It converts deprecations

Factory

  Factory.sequence :login do |n|
    "new_user_\#{n}"
  end
  Factory.define :user do |user|
    user.admin true
    user.login { Factory.next(:login) }
    user.sequence(:email) { |n| "user\#{n}@gmail.com" }
    user.after_create { |instance| create_list(:post, 5, user: instance) }
  end

  =>

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

Test

  Factory(:user) => create(:user)
  Factory.next(:email) => generate(:email)
  Factory.stub(:comment) => build_stubbed(:comment)
  Factory.create(:user) => create(:user)
  Factory.build(:use) => build(:user)
  Factory.attributes_for(:user) => attributes_for(:user)

  EOF

  if_gem 'factory_girl', { gte: '2.0.0' }

  within_files '{test,spec}/factories/**/*.rb' do
    # add
    # FactoryGirl.define do
    # end
    unless_exist_node type: 'send', receiver: 'FactoryGirl', message: 'define' do
      body = node.to_source.gsub("\n", "\n  ")
      replace_with "FactoryGirl.define do
  #{body}
end"
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
    within_node type: 'block', caller: { type: 'send', receiver: 'Factory', message: 'define' }, arguments: { size: 1 } do
      argument = node.arguments.first.to_source
      with_node type: 'block', caller: { type: 'send', receiver: argument } do
        goto_node :caller do
          replace_with "{{message}}#{add_arguments_with_parenthesis_if_necessary}"
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
    %w(after_build after_create).each do |message|
      within_node type: 'block', caller: { type: 'send', message: message } do
        goto_node :caller do
          new_message = message.sub('after_', '')
          replace_with "after(:#{new_message})"
        end
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
    within_node type: 'block', caller: { type: 'send', receiver: 'Factory', message: 'define' }, arguments: { size: 1 } do
      argument = node.arguments.first.to_source
      with_node type: 'send', receiver: argument do
        replace_with '{{message}} {{arguments}}'
      end
    end
  end

  within_files '{test,spec}/factories/**/*.rb' do
    # Factory.define :user do |user|
    # end
    # =>
    # factory :user do
    # end
    within_node type: 'block', caller: { type: 'send', receiver: 'Factory', message: 'define' }, arguments: { size: 1 } do
      goto_node :caller do
        replace_with 'factory {{arguments}}'
      end

      goto_node :arguments do
        replace_with ''
      end
    end

    # Factory.sequence :login do |n|
    #   "new_user_#{n}"
    # end
    # =>
    # sequence :user do |n|
    #   "new_user_#{n}"
    # end
    within_node type: 'block', caller: { type: 'send', receiver: 'Factory', message: 'sequence' }, arguments: { size: 1 } do
      goto_node :caller do
        replace_with 'sequence {{arguments}}'
      end
    end
  end

  within_files '{test,spec}/**/*.rb' do
    # Factory(:user) => create(:user)
    with_node type: 'send', receiver: nil, message: 'Factory' do
      replace_with 'create({{arguments}})'
    end

    # Factory.next(:email) => generate(:email)
    with_node type: 'send', receiver: 'Factory', message: 'next' do
      replace_with 'generate({{arguments}})'
    end

    # Factory.stub(:comment) => build_stubbed(:comment)
    with_node type: 'send', receiver: 'Factory', message: 'stub' do
      replace_with 'build_stubbed({{arguments}})'
    end

    # Factory.create(:user) => create(:user)
    # Factory.build(:use) => build(:user)
    # Factory.attributes_for(:user) => attributes_for(:user)
    %w(create build attributes_for).each do |message|
      with_node type: 'send', receiver: 'Factory', message: message do
        replace_with "#{message}({{arguments}})"
      end
    end
  end
end
