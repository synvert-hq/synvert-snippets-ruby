Synvert::Rewriter.new 'ruby', 'merge_to_square_brackets' do
  description <<-EOF
It converts Hash#merge and Hash#merge! methods to Hash#[]=

    enum.inject({}) do |h, e|
      h.merge(e => e)
    end
    =>
    enum.inject({}) do |h, e|
      h[e] = e
      h
    end

    enum.inject({}) { |h, e| h.merge!(e => e) }
    =>
    enum.inject({}) { |h, e| h[e] = e; h }

    enum.each_with_object({}) do |e, h|
      h.merge!(e => e)
    end
    =>
    enum.each_with_object({}) do |e, h|
      h[e] = e
    end
  EOF

  within_files '**/*.rb' do
    # enum.inject({}) do |h, e|
    #   h.merge(e => e)
    # end
    # =>
    # enum.inject({}) do |h, e|
    #   h[e] = e
    #   h
    # end
    #
    # enum.inject({}) { |h, e| h.merge!(e => e) }
    # =>
    # enum.inject({}) { |h, e| h[e] = e; h }
    within_node type: 'block', caller: {type: 'send', message: 'inject'}, arguments: {size: 2}, body: {size: 1} do
      hash_name = node.arguments.first.name.to_s
      block_start_line = node.line
      %w(merge merge!).each do |message|
        with_node type: 'send', receiver: hash_name, message: message, arguments: {size: 1} do
          merge_line = node.line
          splitter = block_start_line == merge_line ? '; ' : "\n"
          hash_pairs = node.arguments.first.children
          new_code = hash_pairs.map { |pair_node|
            "#{hash_name}[#{pair_node.key.to_source}] = #{pair_node.value.to_source}"
          }.join(splitter)
          replace_with "#{new_code}#{splitter}#{hash_name}"
        end
      end
    end

    # enum.each_with_object({}) do |e, h|
    #   h.merge(e => e)
    # end
    # =>
    # enum.each_with_object({}) do |e, h|
    #   h[e] = e
    # end
    #
    # enum.each_with_object({}) { |e, h| h.merge!(e => e) }
    # =>
    # enum.each_with_object({}) { |e, h| h[e] = e }
    within_node type: 'block', caller: {type: 'send', message: 'each_with_object'}, arguments: {size: 2}, body: {size: 1} do
      hash_name = node.arguments.last.name.to_s
      block_start_line = node.line
      %w(merge merge!).each do |message|
        with_node type: 'send', receiver: hash_name, message: message, arguments: {first: {type: 'hash'}} do
          merge_line = node.line
          splitter = block_start_line == merge_line ? '; ' : "\n"
          hash_pairs = node.arguments.first.children
          new_code = hash_pairs.map { |pair|
            "{{receiver}}[#{pair.key.to_source}] = #{pair.value.to_source}"
          }.join(splitter)
          replace_with new_code
        end
      end
    end
  end
end
