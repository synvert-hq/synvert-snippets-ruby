# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_render_text_to_render_plain' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts `render :text` to `render :plain`

    ```ruby
    render text: 'OK'
    ```

    =>

    ```ruby
    render plain: 'OK'
    ```
  EOS

  if_gem 'actionpack', '>= 5.0'

  within_files Synvert::RAILS_CONTROLLER_FILES do
    with_node node_type: 'call_node',
              receiver: nil,
              name: 'render',
              arguments: {
                node_type: 'arguments_node',
                arguments: { size: 1, first: { node_type: 'keyword_hash_node', text_value: { not: nil } } }
              } do
      old_key = node.arguments.arguments.first.text_element.key.to_source
      replace 'arguments.arguments.0.text_element.key', with: old_key.sub('text', 'plain')
    end
  end
end
