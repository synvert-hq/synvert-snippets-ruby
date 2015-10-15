Synvert::Rewriter.new 'ruby', 'new_hash_syntax' do
  description <<-'EOF'
Use ruby new hash syntax extended in ruby 2.2.

    {:foo => 'bar'} => {foo: 'bar'}
    {:'foo-x' => 'bar'} => {'foo-x': 'bar'}
    {:"foo-#{suffix}" 'bar'} => {"foo-#{suffix}": 'bar'}
  EOF

  # Gem::Version initialize will strip RUBY_VERSION directly in ruby 1.9,
  # which is solved from ruby 2.0.0, which calls dup internally.
  if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new("2.2.0")
    within_files '**/*.rb' do
      # {:foo => 'bar'} => {foo: 'bar'}
      # {:'foo-x' => 'bar'} => {'foo-x': 'bar'}
      # {:"foo-#{suffix}" 'bar'} => {"foo-#{suffix}": 'bar'}
      within_node type: 'hash' do
        with_node type: 'pair' do
          case node.key.type
          when :sym
            case node.key.to_source
            when /\A:"([^"'\\]*)"\z/
              replace_with "'#{$1}': {{value}}"
            when /\A:(.+)\z/
              replace_with "#{$1}: {{value}}"
            end
          when :dsym
            if new_key = node.key.to_source[/\A:(.+)/, 1]
              replace_with "#{new_key}: {{value}}"
            end
          end
        end
      end
    end
  end
end
