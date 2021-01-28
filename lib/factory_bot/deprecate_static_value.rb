Synvert::Rewriter.new 'factory_bot', 'deprecate_static_value' do
  description <<-EOF
It deprecates factory_bot static value

  FactoryBot.define do
    factory :post do
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
  =>
  FactoryBot.define do
    factory :post do
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
  EOF

  within_files '{test,spec}/factories/**/*.rb' do
    def convert_to_new_value(node)
      if node.arguments.size == 1 && node.arguments.first.type == :hash
        new_arguments = add_curly_brackets_if_necessary(node.arguments.first.to_source)
        replace_with "{{message}} { #{new_arguments} }"
      else
        replace_with "{{message}} { {{arguments}} }"
      end
    end
    within_node type: 'block', caller: { type: 'send', message: 'factory' } do
      goto_node :body do
        within_direct_node type: 'send', receiver: nil do
          convert_to_new_value(node)
        end
      end
    end
    within_node type: 'block', caller: { type: 'send', message: 'trait' } do
      goto_node :body do
        within_direct_node type: 'send', receiver: nil do
          convert_to_new_value(node)
        end
      end
    end
  end
end