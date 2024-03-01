# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'prefer_nil' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It prefers .nil?

    https://gist.github.com/postmodern/66dfb41c8cc98f3bc3c2fd2fe7385542

    ```ruby
    value1 == nil
    value2 != nil
    ```

    =>

    ```ruby
    value1.nil?
    !value2.nil?
    ```
  EOS

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    find_node '.call_node[receiver=.call_node[receiver=nil]][name=!=][arguments=.arguments_node[arguments.size=1][arguments.0=.nil_node]]' do
      replace_with '!{{receiver}}.nil?'
    end
    find_node '.call_node[receiver=.call_node[receiver=nil]][name===][arguments=.arguments_node[arguments.size=1][arguments.0=.nil_node]]' do
      replace_with '{{receiver}}.nil?'
    end
  end
end
