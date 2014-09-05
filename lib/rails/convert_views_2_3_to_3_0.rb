Synvert::Rewriter.new 'rails', 'convert_views_2_3_to_3_0' do
  description <<-EOF
1. remove h helper, rails 3 uses it by default.

    <%= h user.login %> => <%= user.login %>

2. use erb expression instead of erb statement for view helpers.

    <% form_for post do |f| %>
    <% end %>
    =>
    <%= form_for post do |f| %>
    <% end %>
  EOF

  %w(app/views/**/*.html.erb app/helpers/**/*.rb).each do |file_pattern|
    # <%= h user.login %> => <%= user.login %>
    within_files file_pattern do
      with_node type: 'send', receiver: nil, message: 'h' do
        replace_with "{{arguments}}"
      end
    end

    %w(form_for form_tag fields_for div_for content_tag_for).each do |message|
      # <% form_for post do |f| %>
      # <% end %>
      # =>
      # <%= form_for post do |f| %>
      # <% end %>
      within_files file_pattern do
        with_node type: 'block', caller: {type: 'send', receiver: nil, message: message} do
          replace_erb_stmt_with_expr
        end
      end
    end
  end
end
