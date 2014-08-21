Synvert::Rewriter.new 'ruby', 'new_hash_syntax' do
  description <<-EOF
Use ruby new hash syntax.

    {:foo => 'bar'} => {foo: 'bar'}
  EOF

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("1.9.0")
    within_files '**/*.rb' do
      # {:foo => 'bar'} => {foo: 'bar'}
      within_node type: 'hash' do
        with_node type: 'pair' do
          if :sym == node.key.type && node.key.to_source[0] == ':' && !%w(' ").include?(node.key.to_source[1])
            new_key = node.key.to_source[1..-1]
            replace_with "#{new_key}: {{value}}"
          end
        end
      end
    end
  end
end
