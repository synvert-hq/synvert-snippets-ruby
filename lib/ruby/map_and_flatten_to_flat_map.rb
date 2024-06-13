# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'map_and_flatten_to_flat_map' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts `map` and `flatten` to `flat_map`

    ```ruby
    enum.map do |item|
      # do something
    end.flatten
    ```

    =>

    ```ruby
    enum.flat_map do |item|
      # do something
    end
    ```
  EOS

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # enum.map do |item|
    #   # do something
    # end.flatten
    # =>
    # enum.flat_map do |item|
    #   # do something
    # end
    find_node '.call_node[receiver=.call_node[name=map][arguments=nil][block=.block_node]][name=flatten][arguments=nil]' do
      group do
        delete :call_operator, :name
        replace 'receiver.name', with: 'flat_map'
      end
    end
  end
end
