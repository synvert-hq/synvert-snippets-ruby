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

  within_files '**/*.rb' do
    # def slow(&block)
    #   block.call
    # end
    # =>
    # def slow
    #   yield
    # end
    within_node type: 'def', arguments: { contain: '&block' } do
      if node.arguments.size > 1
        replace :arguments, with: '{{arguments[0...-1]}}'
      else
        delete :arguments, :parentheses
      end
      goto_node :body do
        with_node type: 'send', receiver: 'block', message: 'call' do
          delete :receiver, :dot
          replace :message, with: 'yield'
        end
      end
    end
  end
end
