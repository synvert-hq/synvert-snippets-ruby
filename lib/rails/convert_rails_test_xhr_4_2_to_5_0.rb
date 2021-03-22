# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_rails_test_xhr_4_2_to_5_0' do
  description <<~EOS
    It converts xhr method in rails test from 4.2 to 5.0.

    ```ruby
    xhr :get, :show
    ```

    =>

    ```ruby
    get :show, xhr: true
    ```
  EOS

  if_gem 'rails', { gte: '5.0' }

  within_files '{test,spec}/{functional,controllers}/**/*.rb' do
    with_node type: 'send', receiver: nil, message: 'xhr', arguments: { size: 2 } do
      method, action = node.arguments.map(&:to_value)
      replace_with("#{method} :#{action}, xhr: true")
    end
  end
end
