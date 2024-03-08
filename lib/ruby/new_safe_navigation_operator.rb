# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'new_safe_navigation_operator' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    Use ruby new safe navigation operator.

    ```ruby
    u.try!(:profile).try(:thumbnails).try(:large, 100, format: 'jpg')
    ```

    =>

    ```ruby
    u&.profile&.thumbnails&.large(100, format: 'jpg')
    ```
  EOS

  if_ruby '2.3.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # u.try!(:profile).try!(:thumbnails).try!(:large, 100, format: 'jpg')
    # u.try(:profile).try(:thumbnails).try(:large, 100, format: 'jpg')
    # =>
    # u&.profile&.thumbnails&.large(100, format: 'jpg')
    # u&.profile&.thumbnails&.large(100, format: 'jpg')
    find_node '.call_node[name IN (try try!)][arguments != nil][arguments.arguments.size > 0]' do
      group do
        insert '&', to: 'receiver'
        replace :message, with: '{{arguments.arguments.first.to_value}}'
        if node.arguments.arguments.size == 1
          delete :opening, :arguments, :closing
        else
          delete 'arguments.arguments.first', and_comma: true
        end
      end
    end
  end
end
