# frozen_string_literal: true

require 'securerandom'

Synvert::Rewriter.new 'rails', 'convert_routes_3_2_to_4_0' do
  configure(parser: Synvert::PARSER_PARSER)

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
    with_node node_type: 'send', receiver: 'Rack::Utils', message: 'escape' do
      replace_with '{{arguments}}'
    end

    # match "/" => "root#index" => get "/" => "root#index"
    with_node node_type: 'send', message: 'match' do
      replace_with 'get {{arguments}}'
    end
  end

  within_files Synvert::RAILS_VIEW_FILES do
    # link_to 'delete', post_path(post), confirm: 'Are you sure to delete post?'
    # =>
    # link_to 'delete', post_path(post), data: { confirm: 'Are you sure to delete post?' }
    within_node node_type: 'send', message: 'link_to', arguments: { last: { node_type: 'hash' } } do
      if node.arguments.last.key?(:confirm)
        hash = node.arguments.last
        other_arguments_str = node.arguments[0...-1].map(&:to_source).join(', ')
        confirm = hash.confirm_source
        other_options =
          hash.children.map { |pair|
            unless %i[confirm data].include?(pair.key.to_value)
              if pair.key.type == :sym
                "#{pair.key.to_value}: #{pair.value.to_source}"
              else
                "#{pair.key.to_source} => #{pair.value.to_source}"
              end
            end
          }.compact.join(', ')
        data_options = "data: { confirm: #{confirm} }"
        replace_with "link_to #{other_arguments_str}, #{other_options}, #{data_options}"
      end
    end
  end
end
