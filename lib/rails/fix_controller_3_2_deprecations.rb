# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'fix_controller_3_2_deprecations' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It fixes rails 3.2 controller deprecations.

    ```ruby
    ActionController::UnknownAction
    ```

    =>

    ```ruby
    AbstractController::ActionNotFound
    ```

    ```ruby
    ActionController::DoubleRenderError
    ```

    =>

    ```ruby
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
      with_node type: 'const', to_source: old_const do
        replace_with new_const
      end
    end
  end
end
