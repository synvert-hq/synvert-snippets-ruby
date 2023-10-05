# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'map_and_flatten_to_flat_map' do
  configure(parser: Synvert::PARSER_PARSER)

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

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # enum.map do
    #   # do something
    # end.flatten
    # =>
    # enum.flat_map do
    #   # do something
    # end
    find_node '.send [receiver=.block [caller=.send[message=map]]] [message=flatten] [arguments.size=0]' do
      group do
        delete :message, :dot
        replace 'receiver.caller.message', with: 'flat_map'
      end
    end
  end
end
