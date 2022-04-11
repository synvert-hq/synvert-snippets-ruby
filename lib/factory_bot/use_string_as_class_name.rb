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
    within_node type: 'block',
                caller: {
                  type: 'send',
                  message: 'factory',
                  arguments: {
                    length: 2,
                    second: { type: 'hash', class_value: { type: 'const' } }
                  }
                } do
      replace 'caller.arguments.second.class_value', with: "'{{caller.arguments.second.class_value}}'"
    end
  end
end
