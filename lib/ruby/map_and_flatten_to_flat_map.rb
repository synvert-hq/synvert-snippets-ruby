# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'map_and_flatten_to_flat_map' do
  description <<~EOS
    It converts `map` and `flatten` to `flat_map`

    ```ruby
    enum.map do
      # do something
    end.flatten
    ```

    =>

    ```ruby
    enum.flat_map do
      # do something
    end
    ```
  EOS

  within_files '**/*.rb' do
    # enum.map do
    #   # do something
    # end.flatten
    # =>
    # enum.flat_map do
    #   # do something
    # end
    with_node type: 'send', receiver: { type: 'block', caller: { type: 'send', message: 'map' } }, message: 'flatten', arguments: { size: 0 } do
      delete :message, :dot
      goto_node :receiver do
        with_node type: 'block' do
          goto_node :caller do
            replace :message, with: 'flat_map'
          end
        end
      end
    end
  end
end
