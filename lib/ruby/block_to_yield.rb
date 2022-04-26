# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'block_to_yield' do
  description <<~EOS
    It converts block to yield.

    ```ruby
    def slow(&block)
      block.call
    end
    ```

    =>

    ```ruby
    def slow
      yield
    end
    ```
  EOS

  within_files Synvert::ALL_RUBY_FILES do
    # def slow(&block)
    #   block.call
    # end
    # =>
    # def slow
    #   yield
    # end
    find_node '.def[arguments INCLUDES &block]' do
      if node.arguments.size > 1
        delete 'arguments.last'
      else
        delete :arguments, :parentheses
      end
      find_node '.send[receiver=block][message=call]' do
        delete :receiver, :dot
        replace :message, with: 'yield'
      end
    end
  end
end
