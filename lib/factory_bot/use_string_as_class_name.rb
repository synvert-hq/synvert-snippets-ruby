# frozen_string_literal: true

Synvert::Rewriter.new 'factory_bot', 'use_string_as_class_name' do
  configure(parser: Synvert::PARSER_PARSER)

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
    find_node '.block[caller=.send[message=factory][arguments.size=2][arguments.-1=.hash[class_value=.const]]]' do
      replace 'caller.arguments.-1.class_value', with: wrap_with_quotes(node.caller.arguments.last.class_source)
    end
  end
end
