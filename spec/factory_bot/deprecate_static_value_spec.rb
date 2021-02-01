# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Deprecate factory_bot static value' do
  let(:rewriter_name) { 'factory_bot/deprecate_static_value' }
  let(:fake_file_path) { 'spec/factories/post.rb' }
  let(:test_content) { '
FactoryBot.define do
  factory :post do
    user
    association :user
    title "Something"
    comments_count 0
    tag Tag::MAGIC
    recent_statuses []
    status([:draft, :published].sample)
    published_at 1.day.from_now
    created_at(1.day.ago)
    updated_at Time.current
    update_times [Time.current]
    meta_tags(foo: Time.current)
    other_tags({ foo: Time.current })
    options color: :blue
    trait :old do
      published_at 1.week.ago
    end
    transient do
      rockstar true
    end
  end
end
  '}
  let(:test_rewritten_content) { '
FactoryBot.define do
  factory :post do
    user
    association :user
    title { "Something" }
    comments_count { 0 }
    tag { Tag::MAGIC }
    recent_statuses { [] }
    status { [:draft, :published].sample }
    published_at { 1.day.from_now }
    created_at { 1.day.ago }
    updated_at { Time.current }
    update_times { [Time.current] }
    meta_tags { { foo: Time.current } }
    other_tags { { foo: Time.current } }
    options { { color: :blue } }
    trait :old do
      published_at { 1.week.ago }
    end
    transient do
      rockstar { true }
    end
  end
end
  '}

  include_examples 'convertable'
end
