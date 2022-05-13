# frozen_string_literal: true

Synvert::Rewriter.new 'factory_bot', 'deprecate_static_value' do
  description <<~EOS
    It deprecates factory_bot static value

    ```ruby
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
      end
    end
    ```

    =>

    ```ruby
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
      end
    end
    ```
  EOS

  if_gem 'factory_bot', '>= 4.11'

  within_files Synvert::RAILS_FACTORY_FILES do
    find_node ".block[caller=.send[message IN (factory transient trait)]] <body>
              > .send[receiver=nil][message NOT IN (association sequence before after factory callback)][arguments.size=1]" do
      if node.arguments.first.type == :hash
        new_arguments = add_curly_brackets_if_necessary(node.arguments.first.to_source)
        replace :arguments, with: "{ #{new_arguments} }"
      else
        replace :arguments, with: '{ {{arguments}} }'
      end
    end
  end
end
