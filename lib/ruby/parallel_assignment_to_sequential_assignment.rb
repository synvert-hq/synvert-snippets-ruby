# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'parallel_assignment_to_sequential_assignment' do
  description <<-EOF
It converts parallel assignment to sequential assignment.

    a, b = 1, 2
    =>
    a = 1
    b = 2
  EOF

  within_files '**/*.rb' do
    # a, b = 1, 2
    # =>
    # a = 1
    # b = 2
    with_node type: 'masgn' do
      left_value = node.left_value
      right_value = node.right_value
      if left_value.type == :mlhs && right_value.type == :array && left_value.children.size == right_value.children.size
        replace_with left_value.children.zip(right_value.children).map { |left, right|
                       "#{left.to_source} = #{right.to_source}"
                     }.join("\n")
      end
    end
  end
end
