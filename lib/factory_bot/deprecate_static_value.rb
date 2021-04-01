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

  within_files '{test,spec}/factories/**/*.rb' do
    %w[factory transient trait].each do |message|
      within_node type: 'block', caller: { type: 'send', message: message } do
        goto_node :body do
          within_direct_node type: 'send', receiver: nil do
            next if node.arguments.empty?
            next if %i[association sequence before after factory callback].include?(node.message)

            if node.arguments.size == 1 && node.arguments.first.type == :hash
              new_arguments = add_curly_brackets_if_necessary(node.arguments.first.to_source)
              replace :arguments, with: "{ #{new_arguments} }"
            else
              replace :arguments, with: '{ {{arguments}} }'
            end
          end
        end
      end
    end
  end
end
