# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_controller_filter_to_action' do
  description <<~EOS
    It renames before_filter callbacks to before_action

    ```ruby
    class PostsController < ApplicationController
      skip_filter :authorize
      before_filter :load_post
      after_filter :track_post
      around_filter :log_post
    end
    ```

    =>

    ```ruby
    class PostsController < ApplicationController
      skip_action_callback :authorize
      before_action :load_post
      after_action :track_post
      around_action :log_post
    end
    ```
  EOS

  if_gem 'actionpack', { gte: '4.0.0' }

  within_files 'app/controllers/**/*.rb' do
    # skip_filter :load_post => skip_action_callback :load_post
    # before_filter :load_post => before_action :load_post
    # after_filter :increment_view_count => after_filter :increment_view_count
    with_node type: 'send', receiver: nil, message: /_filter$/ do
      new_message =
        if node.message == :skip_filter
          'skip_action_callback'
        else
          node.message.to_s.sub('filter', 'action')
        end
      replace_with "#{new_message} {{arguments}}"
    end
  end
end
