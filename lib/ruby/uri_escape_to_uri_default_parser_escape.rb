# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'uri_escape_to_uri_default_parser_escape' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    Use URI::DEFAULT_PARSER.escape instead of URI.escape.

    ```ruby
    URI.escape(url)
    URI.encode(url)
    ```

    =>

    ```ruby
    URI::DEFAULT_PARSER.escape(url)
    URI::DEFAULT_PARSER.escape(url)
    ```
  EOS

  if_ruby '2.7.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # URI.escape(url) => URI::DEFAULT_PARSER.escape(url)
    # URI.encode(url) => URI::DEFAULT_PARSER.escape(url)
    find_node '.call_node[receiver=URI][name IN (escape encode)][arguments=.arguments_node[arguments.size=1]]' do
      group do
        replace :receiver, with: '{{receiver}}::DEFAULT_PARSER'
        replace :message, with: 'escape'
      end
    end
  end
end
