# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'kernel_open_to_uri_open' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts `Kernel#open` to `URI.open`

    ```ruby
    open('http://test.com')
    ```

    =>

    ```ruby
    URI.open('http://test.com')
    ```
  EOS

  if_ruby '2.7.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # open('http://test.com')
    # =>
    # URI.open('http://test.com')
    unless_exist_node('.def_node[name=open]') do
      find_node '.call_node[receiver=nil][name=open][arguments=.arguments_node[arguments.size IN (1 2)]]' do
        insert 'URI.', to: 'name', at: 'beginning'
      end
    end
  end
end
