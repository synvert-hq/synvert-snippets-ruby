# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_to_response_parsed_body' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts `JSON.parse(@response.body)` to `@response.parsed_body`.
  EOS

  if_gem 'rails', '>= 5.0'

  within_files Synvert::RAILS_CONTROLLER_TEST_FILES do
    with_node node_type: 'send',
              receiver: 'JSON',
              message: 'parse',
              arguments: {
                size: 1,
                '0': {
                  node_type: 'send',
                  receiver: { in: ['response', '@response'] },
                  message: 'body',
                  arguments: { size: 0 }
                }
              } do
      replace_with '{{arguments.0.receiver}}.parsed_body'
    end
  end
end
