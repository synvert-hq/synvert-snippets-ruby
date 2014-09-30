Synvert::Rewriter.new 'ruby', 'fast_syntax' do
  description <<-EOF
Use ruby fast syntax

    def slow(&block)
      block.call
    end
    =>
    def slow
      yield
    end

    (1..100).map { |i| i.to_s }
    =>
    (1..100).map(&:to_s)

    enum.map do
      # do something
    end.flatten(1)
    =>
    enum.flat_map do
      # do something
    end

    enum.inject({}) do |h, e|
      h.merge(e => e)
    end
    =>
    enum.inject({}) do |h, e|
      h.merge!(e => e)
    end

    enum.each_with_object({}) do |e, h|
      h.merge!(e => e)
    end
    =>
    enum.each_with_object({}) do |e, h|
      h[e] = e
    end

    {:rails => :club}.fetch(:rails, (0..9).to_a)
    =>
    {:rails => :club}.fetch(:rails) { (0..9).to_a }

    'slug from title'.gsub(' ', '_')
    =>
    'slug from title'.tr(' ', '_')

    a, b = 1, 2
    =>
    a = 1
    b = 2

    array.each_with_index |number, index|
      test(number, index)
    end
    =>
    index = 0
    while index < array.size
      number = array[index]
      test(number, index)
      index += 1
    end

    reference: https://speakerdeck.com/sferik/writing-fast-ruby
  EOF

  within_files '**/*.rb' do
    # def slow(&block)
    #   block.call
    # end
    # =>
    # def slow
    #   yield
    # end
    within_node type: 'def', arguments: {last: {type: 'blockarg'}} do
      block_arg_name = node.arguments.last.name.to_s
      block_called = false
      with_node type: 'send', receiver: block_arg_name, message: 'call' do
        block_called = true
        replace_with "yield {{arguments}}"
      end
      if block_called
        goto_node :arguments do
          if node.size > 1
            replace_with "({{children[0..-2]}})"
          else
            replace_with ""
          end
        end
      end
    end

    # (1..100).map { |i| i.to_s }
    # =>
    # (1..100).map(&:to_s)
    with_node type: 'block', caller: {message: 'map'}, arguments: {size: 1} do
      argument_name = node.arguments.first.name.to_s
      if_only_exist_node type: 'send', receiver: argument_name do
        message = node.body.first.message
        replace_with "{{caller}}(&:#{message})"
      end
    end

    # enum.map do
    #   # do something
    # end.flatten(1)
    # =>
    # enum.flat_map do
    #   # do something
    # end
    with_node type: 'send', receiver: {type: 'block', caller: {type: 'send', message: 'map'}}, message: 'flatten', arguments: [1] do
      replace_with "{{receiver.to_source.sub('.map', '.flat_map')}}"
    end

    # enum.inject({}) do |h, e|
    #   h.merge(e => e)
    # end
    # =>
    # enum.inject({}) do |h, e|
    #   h.merge!(e => e)
    # end
    within_node type: 'block', caller: {type: 'send', message: 'inject'}, arguments: {size: 2}, body: {size: 1} do
      hash_name = node.arguments.first.name.to_s
      with_node type: 'send', receiver: hash_name, message: 'merge' do
        replace_with "{{receiver}}.merge!({{arguments}})"
      end
    end

    # enum.each_with_object({}) do |e, h|
    #   h.merge!(e => e)
    # end
    # =>
    # enum.each_with_object({}) do |e, h|
    #   h[e] = e
    # end
    within_node type: 'block', caller: {type: 'send', message: 'each_with_object'}, arguments: {size: 2}, body: {size: 1} do
      hash_name = node.arguments.last.name.to_s
      with_node type: 'send', receiver: hash_name, message: 'merge!', arguments: {first: {type: 'hash'}} do
        new_code = []
        hash_pairs = node.arguments.first.children
        hash_pairs.each do |pair|
          new_code << "{{receiver}}[#{pair.key.to_source}] = #{pair.value.to_source}"
        end
        replace_with new_code.join("\n")
      end
    end

    # {:rails => :club}.fetch(:rails, (0..9).to_a)
    # =>
    # {:rails => :club}.fetch(:rails) { (0..9).to_a }
    with_node type: 'send', receiver: {not: nil}, message: 'fetch', arguments: {size: 2} do
      replace_with "{{receiver}}.fetch({{arguments.first}}) { {{arguments.last}} }"
    end

    # 'slug from title'.gsub(' ', '_')
    # =>
    # 'slug from title'.tr(' ', '_')
    with_node type: 'send', message: 'gsub', arguments: {size: 2, first: {type: 'str'}, last: {type: 'str'}} do
      if node.arguments.first.to_value.length == 1
        replace_with "{{receiver}}.tr({{arguments}})"
      end
    end

    # a, b = 1, 2
    # =>
    # a = 1
    # b = 2
    with_node type: 'masgn' do
      if node.left_value.size == node.right_value.size
        replace_with node.left_value.zip(node.right_value).map { |left, right| "#{left.to_source} = #{right.to_source}" }.join("\n")
      end
    end

    # array.each_with_index do |number, index|
    #   test(number, index)
    # end
    # =>
    # index = 0
    # while index < array.size
    #   number = array[index]
    #   test(number, index)
    #   index += 1
    # end
    with_node type: 'block', caller: {message: 'each_with_index'} do
      array = node.caller.receiver.to_source
      element = node.arguments.first.to_source
      index = node.arguments.last.to_source
      replace_with "index = 0
while #{index} < #{array}.size
  #{element} = #{array}[#{index}]
  {{body}}
  #{index} += 1
end"
    end
  end
end
