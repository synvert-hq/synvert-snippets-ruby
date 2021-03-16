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

  helper_method :replace_hash_key do |hash_node, old_key, new_key|
    hash_node.children.map { |pair_node|
      pair_node.key.to_value == old_key ? pair_node.to_source.sub(old_key.to_s, new_key.to_s) : pair_node.to_source
    }.join(', ')
  end

  within_files 'app/controllers/**/*.rb' do
    with_node type: 'send', receiver: nil, message: 'render', arguments: { size: 1, first: { type: 'hash' } } do
      hash_node = node.arguments.first
      if hash_node.has_key?(:text)
        replace_with "render #{replace_hash_key(hash_node, :text, :plain)}"
      end
    end
  end
end
