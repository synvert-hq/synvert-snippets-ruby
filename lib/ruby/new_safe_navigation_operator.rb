# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'new_safe_navigation_operator' do
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

  within_files Synvert::ALL_RUBY_FILES do
    # u.try!(:profile).try!(:thumbnails).try!(:large, 100, format: 'jpg')
    # u.try(:profile).try(:thumbnails).try(:large, 100, format: 'jpg')
    # =>
    # u&.profile&.thumbnails&.large(100, format: 'jpg')
    # u&.profile&.thumbnails&.large(100, format: 'jpg')
    %w[try! try].each do |message|
      within_node type: 'send', message: message do
        if node.arguments.size > 0
          insert '&', to: 'receiver'
          replace :message, with: '{{arguments.first.to_value}}'
          if node.arguments.size == 1
            delete :arguments, :parentheses
          else
            delete 'arguments.first'
          end
        end
      end
    end
  end
end
