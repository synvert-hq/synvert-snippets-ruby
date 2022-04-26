# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'merge_to_square_brackets' do
  description <<~EOS
    It converts `Hash#merge` and `Hash#merge!` methods to `Hash#[]=`

    ```ruby
    enum.inject({}) do |h, e|
      h.merge(e => e)
    end
    ```

    =>

    ```ruby
    enum.inject({}) do |h, e|
      h[e] = e
      h
    end
    ```

    ```ruby
    enum.inject({}) { |h, e| h.merge!(e => e) }
    ```

    =>

    ```ruby
    enum.inject({}) { |h, e| h[e] = e; h }
    ```

    ```ruby
    enum.each_with_object({}) do |e, h|
      h.merge!(e => e)
    end
    ```

    =>

    ```ruby
    enum.each_with_object({}) do |e, h|
      h[e] = e
    end
    ```
  EOS

  helper_method :hash_node_to_square_brackets_code do |hash_node, splitter|
    hash_node.children.map { |pair_node|
      if pair_node.key.type == :sym
        "{{receiver}}[:#{pair_node.key.to_value}] = #{pair_node.value.to_source}"
      else
        "{{receiver}}[#{pair_node.key.to_source}] = #{pair_node.value.to_source}"
      end
    }.join(splitter)
  end

  within_files Synvert::ALL_RUBY_FILES do
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
    find_node '.block[caller=.send[message=inject]][arguments.size=2][body.size=1]' do
      # within_node type: 'block', caller: { type: 'send', message: 'inject' }, arguments: { size: 2 }, body: { size: 1 } do
      hash_name = node.arguments.first.name.to_s
      block_start_line = node.line
      %w[merge merge!].each do |message|
        find_node ".send[receiver=#{hash_name}][message=#{message}][arguments=[size=1][first=.hash]]" do
          merge_line = node.line
          splitter = block_start_line == merge_line ? '; ' : "\n"
          new_code = hash_node_to_square_brackets_code(node.arguments.first, splitter)
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
    find_node '.block[caller=.send[message=each_with_object]][arguments.size=2][body.size=1]' do
      hash_name = node.arguments.last.name.to_s
      block_start_line = node.line
      %w[merge merge!].each do |message|
        find_node ".send[receiver=#{hash_name}][message=#{message}][arguments=[size=1][first=.hash]]" do
          merge_line = node.line
          splitter = block_start_line == merge_line ? '; ' : "\n"
          new_code = hash_node_to_square_brackets_code(node.arguments.first, splitter)
          replace_with new_code
        end
      end
    end
  end

  within_files Synvert::ALL_RUBY_FILES do
    # hash.merge!(e => e)
    # =>
    # hash[e] = e
    find_node '.send[receiver!=nil][message=merge!][arguments=[size=1][first=.hash]]' do
      new_code = hash_node_to_square_brackets_code(node.arguments.first, "\n")
      replace_with new_code
    end
  end
end
