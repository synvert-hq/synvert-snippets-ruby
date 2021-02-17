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

  within_files '**/*.rb' do
    # u.try!(:profile).try!(:thumbnails).try!(:large, 100, format: 'jpg')
    # u.try(:profile).try(:thumbnails).try(:large, 100, format: 'jpg')
    # =>
    # u.?profile.?thumbnails.?large(100, format: 'jpg')
    # u.?profile.?thumbnails.?large(100, format: 'jpg')
    %w(try! try).each do |message|
      within_node type: 'send', message: message do
        case node.arguments.size
        when 0
          # Do nothing
        when 1
          replace_with '{{receiver}}&.{{arguments.first.to_value}}'
        else
          replace_with '{{receiver}}&.{{arguments.first.to_value}}({{arguments[1..-1]}})'
        end
      end
    end
  end
end
