# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_constants_3_1_to_3_2' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts rails constants from 3.1 to 3.2.

    ```ruby
    ActionController::UnknownAction
    ActionController::DoubleRenderError
    ```

    =>

    ```ruby
    AbstractController::ActionNotFound
    AbstractController::DoubleRenderError
    ```
  EOS

  if_gem 'actionpack', '>= 3.2'

  within_files Synvert::RAILS_CONTROLLER_FILES do
    # ActionController::UnknownAction => AbstractController::ActionNotFound
    # ActionController::DoubleRenderError => AbstractController::DoubleRenderError
    {
      'ActionController::UnknownAction' => 'AbstractController::ActionNotFound',
      'ActionController::DoubleRenderError' => 'AbstractController::DoubleRenderError'
    }.each do |old_const, new_const|
      with_node node_type: 'constant_path_node', to_source: old_const do
        replace_with new_const
      end
    end
  end
end
