Synvert::Rewriter.new 'ruby', 'use_symbol_to_proc' do
  description <<-EOF
It uses &: (short for symbol to proc)

    (1..100).each { |i| i.to_s }
    =>
    (1..100).each(&:to_s)

    (1..100).map { |i| i.to_s }
    =>
    (1..100).map(&:to_s)
  EOF

  within_files '**/*.rb' do
    # (1..100).each { |i| i.to_s }
    # =>
    # (1..100).each(&:to_s)
    #
    # (1..100).map { |i| i.to_s }
    # =>
    # (1..100).map(&:to_s)
    %w[each map].each do |message|
      with_node type: 'block', caller: { message: message }, arguments: { size: 1 } do
        argument_name = node.arguments.first.name.to_s
        if_only_exist_node type: 'send', receiver: argument_name, arguments: { size: 0 } do
          message = node.body.first.message
          replace_with "{{caller}}(&:#{message})"
        end
      end
    end
  end
end
