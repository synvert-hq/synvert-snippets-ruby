Synvert::Rewriter.new 'ruby', 'block_to_yield' do
  description <<-EOF
It converts block to yield.

    def slow(&block)
      block.call
    end
    =>
    def slow
      yield
    end
  EOF

  within_files '**/*.rb' do
    # def slow(&block)
    #   block.call
    # end
    # =>
    # def slow
    #   yield
    # end
    within_node type: 'def', arguments: { last: { type: 'blockarg' } } do
      block_arg_name = node.arguments.last.name.to_s
      block_called = false
      with_node type: 'send', receiver: block_arg_name, message: 'call' do
        block_called = true
        replace_with "yield#{add_arguments_with_parenthesis_if_necessary}"
      end
      if block_called
        goto_node :arguments do
          if node.children.size > 1
            replace_with '({{children[0..-2]}})'
          else
            replace_with ''
          end
        end
      end
    end
  end
end
