# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_render_text_to_render_plain' do
  description <<~EOS
    It convert `render :text` to `render :plain`

    ```ruby
    render text: 'OK'
    ```

    =>

    ```ruby
    render plain: 'OK'
    ```
  EOS

  within_files 'app/controllers/**/*.rb' do
    with_node type: 'send', receiver: nil, message: 'render', arguments: { size: 1, first: { type: 'hash' } } do
      hash_node = node.arguments.first
      if hash_node.has_key?(:text)
        replace_with "render plain: #{hash_node.hash_value(:text).to_source}"
      end
    end
  end
end
