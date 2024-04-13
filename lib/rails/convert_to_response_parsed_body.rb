# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_to_response_parsed_body' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts `JSON.parse(@response.body)` to `@response.parsed_body`.
  EOS

  if_gem 'rails', '>= 5.0'

  within_files Synvert::RAILS_CONTROLLER_TEST_FILES do
    with_node node_type: 'call_node',
              receiver: 'JSON',
              name: 'parse',
              arguments: {
                node_type: 'arguments_node',
                arguments: {
                  size: 1,
                  first: {
                    node_type: 'call_node',
                    receiver: { in: ['response', '@response'] },
                    message: 'body',
                    arguments: nil
                  }
                }
              } do
      replace_with '{{arguments.arguments.0.receiver}}.parsed_body'
    end
  end
end
