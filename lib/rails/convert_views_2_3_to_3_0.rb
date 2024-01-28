# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_views_2_3_to_3_0' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    1. remove `h` helper, rails 3 uses it by default.

    ```erb
    <%= h user.login %>
    ```

    =>

    ```erb
    <%= user.login %>
    ```

    2. use erb expression instead of erb statement for view helpers.

    ```erb
    <% form_for post do |f| %>
    <% end %>
    ```

    =>

    ```erb
    <%= form_for post do |f| %>
    <% end %>
    ```
  EOS

  if_gem 'actionview', '>= 3.0'

  within_files Synvert::RAILS_VIEW_FILES + Synvert::RAILS_HELPER_FILES do
    # <%= h user.login %> => <%= user.login %>
    with_node node_type: 'send', receiver: nil, message: 'h' do
      replace_with '{{arguments}}'
    end

    # <% form_for post do |f| %>
    # <% end %>
    # =>
    # <%= form_for post do |f| %>
    # <% end %>
    with_node node_type: 'block',
              caller: {
                node_type: 'send',
                receiver: nil,
                message: { in: %w[form_for form_tag fields_for div_for content_tag_for] }
              } do
      replace_erb_stmt_with_expr
    end
  end
end
