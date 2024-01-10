# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'migrate-ujs-to-turbo' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It migrates rails ujs to turbo.

    ```ruby
    <%= link_to "Destroy", post_path(post), method: :delete %>
    <%= link_to "Destroy", post_path(post), method: :delete, data: { confirm: 'Are you sure?' } %>
    <%= submit_tag "Create", data: { disable_with: "Submitting..." } %>
    ```

    =>

    ```ruby
    <%= link_to "Destroy", post_path(post), data: { turbo_method: :delete } %>
    <%= link_to "Destroy", post_path(post), data: { turbo_method: :delete, turbo_confirm: 'Are you sure?' } %>
    <%= submit_tag "Create", data: { turbo_submits_with: "Submitting..." } %>
    ```
  EOS

  within_files Synvert::RAILS_VIEW_FILES do
    # link_to "Destroy", post_path(post), method: :delete, data: { confirm: 'Are you sure?' }
    # link_to "Destroy", post_path(post), data: { turbo_method: :delete }
    find_node '.send[receiver=nil][message=link_to][arguments.size=3][arguments.2=.hash[method_value=:delete][data_value=.hash[confirm_value!=nil]]]' do
      delete 'arguments.2.method_pair', and_comma: true
      insert 'turbo_method: {{arguments.2.method_source}}',
             to: 'arguments.2.data_value.pairs.0',
             at: 'beginning',
             and_comma: true
      replace 'arguments.2.data_value.confirm_pair.key', with: 'turbo_confirm'
    end

    # link_to "Destroy", post_path(post), method: :delete
    # =>
    # link_to "Destroy", post_path(post), data: { turbo_method: :delete }
    find_node '.send[receiver=nil][message=link_to][arguments.size=3][arguments.2=.hash[method_value=:delete][data_value=nil]]' do
      delete 'arguments.2.method_pair', and_comma: true
      insert 'data: { turbo_method: {{arguments.2.method_source}} }', to: 'arguments.2', at: 'end', and_comma: true
    end

    # submit_tag "Create", data: { disable_with: "Submitting..." }
    # =>
    # submit_tag "Create", data: { turbo_submits_with: "Submitting..." }
    find_node '.send[receiver=nil][message=submit_tag][arguments.size=2][arguments.1=.hash[data_value=.hash[disable_with_value!=nil]]]' do
      replace "arguments.1.data_value.disable_with_pair.key", with: 'turbo_submits_with'
    end
  end
end
