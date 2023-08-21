# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'uri_escape_to_uri_default_parser_escape' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Use URI::DEFAULT_PARSER.escape instead of URI.escape.

    ```ruby
    URI.escape(url)
    ```

    =>

    ```ruby
    URI::DEFAULT_PARSER.escape(url)
    ```
  EOS

  if_ruby '3.0.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # URI.escape(url) => URI::DEFAULT_PARSER.escape(url)
    find_node '.send[receiver=URI][message=escape][arguments.size=1]' do
      replace :receiver, with: 'URI::DEFAULT_PARSER'
    end
  end
end
