# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'new_2_2_hash_syntax' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~'EOS'
    Use ruby 2.2 new hash syntax.

    ```ruby
    { :foo => 'bar' }
    { :'foo-x' => 'bar' }
    { :"foo-#{suffix}" 'bar' }
    ```

    =>

    ```ruby
    { foo: 'bar' }
    { 'foo-x': 'bar' }
    { "foo-#{suffix}": 'bar' }
    ```
  EOS

  add_snippet 'ruby', 'new_1_9_hash_syntax'

  if_ruby '2.2.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # {:foo => 'bar'} => {foo: 'bar'}
    # {:'foo-x' => 'bar'} => {'foo-x': 'bar'}
    # {:"foo-#{suffix}" 'bar'} => {"foo-#{suffix}": 'bar'}
    find_node '.hash > .pair' do
      case node.key.type
      when :sym
        case node.key.to_source
        when /\A:"([^"'\\]*)"\z/
          replace_with "'#{Regexp.last_match(1)}': {{value}}"
        when /\A:(.+)\z/
          replace_with "#{Regexp.last_match(1)}: {{value}}"
        end
      when :dsym
        if new_key = node.key.to_source[/\A:(.+)/, 1]
          replace_with "#{new_key}: {{value}}"
        end
      end
    end
  end
end
