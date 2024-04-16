# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_routes_3_2_to_4_0' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts rails routes from 3.2 to 4.0.

    1. it removes `Rack::Utils.escape` in config/routes.rb.

    ```ruby
    Rack::Utils.escape('こんにちは') => 'こんにちは'
    ```

    2. it replaces match in config/routes.rb.

    ```ruby
    match "/" => "root#index"
    ```

    =>

    ```ruby
    get "/" => "root#index"
    ```
  EOS

  if_gem 'rails', '>= 4.0'

  within_file Synvert::RAILS_ROUTE_FILES do
    # Rack::Utils.escape('こんにちは') => 'こんにちは'
    with_node node_type: 'call_node', receiver: 'Rack::Utils', name: 'escape' do
      replace_with '{{arguments.arguments}}'
    end

    # match "/" => "root#index" => get "/" => "root#index"
    with_node node_type: 'call_node', name: 'match' do
      replace :message, with: 'get'
    end
  end
end
