# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'parallel_assignment_to_sequential_assignment' do
  description <<~EOS
    It converts parallel assignment to sequential assignment.

    ```ruby
    a, b = 1, 2
    ```

    =>

    ```ruby
    a = 1
    b = 2
    ```
  EOS

  within_files Synvert::ALL_RUBY_FILES do
    # a, b = 1, 2
    # =>
    # a = 1
    # b = 2
    find_node '.masgn[variable=.mlhs][value=.array][variable.children.size="{{value.children.size}}"]' do
      replace_with node.variable.children.zip(node.value.children).map { |left, right|
        "#{left.to_source} = #{right.to_source}"
      }.join("\n")
    end
  end
end
