# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_controller_filter_to_action' do
  configure(parser: Synvert::PRISM_PARSER)

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

  if_gem 'actionpack', '>= 4.0'

  within_files Synvert::RAILS_CONTROLLER_FILES do
    # skip_filter :load_post => skip_action_callback :load_post
    # before_filter :load_post => before_action :load_post
    # after_filter :increment_view_count => after_filter :increment_view_count
    with_node node_type: 'call_node', receiver: nil, name: /_filter\z/ do
      new_message =
        if node.name == :skip_filter
          'skip_action_callback'
        else
          node.name.to_s.sub('filter', 'action')
        end
      replace :message, with: new_message
    end
  end
end
