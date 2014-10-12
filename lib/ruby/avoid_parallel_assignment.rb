Synvert::Rewriter.new 'ruby', 'avoid_parallel_assignment' do
  description <<-EOF
It avoids parallel assignment

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
      if node.left_value.size == node.right_value.size
        replace_with node.left_value.zip(node.right_value).map { |left, right| "#{left.to_source} = #{right.to_source}" }.join("\n")
      end
    end
  end
end
