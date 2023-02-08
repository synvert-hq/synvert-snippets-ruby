# frozen_string_literal: true

Synvert::Rewriter.new 'factory_bot', 'use_string_as_class_name' do
  description <<~EOS
    It uses string as class name

    ```ruby
    FactoryBot.define do
      factory :admin, class: User do
        name { 'Admin' }
      end
    end
    ```

    =>

    ```ruby
    FactoryBot.define do
      factory :admin, class: 'User' do
        name { 'Admin' }
      end
    end
    ```
  EOS

  within_files Synvert::RAILS_FACTORY_FILES do
    find_node '.block[caller=.send[message=factory][arguments.size=2]] caller.arguments
                     .hash:has(.pair[key=class][value=.const])' do
      replace 'class_value', with: wrap_with_quotes(node.class_source)
    end
  end
end
