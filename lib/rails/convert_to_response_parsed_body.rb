# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_to_response_parsed_body' do
  description <<~EOS
    It converts `JSON.parse(@response.body)` to `@response.parsed_body`.
  EOS

  if_gem 'rails', '>= 5.0'

  within_files Synvert::RAILS_CONTROLLER_TEST_FILES do
    with_node type: 'send',
              receiver: 'JSON',
              message: 'parse',
              arguments: {
                size: 1,
                first: { type: 'send', receiver: '@response', message: 'body', arguments: { size: 0 } }
              } do
      replace_with '@response.parsed_body'
    end

    with_node type: 'send',
              receiver: 'JSON',
              message: 'parse',
              arguments: {
                size: 1,
                first: { type: 'send', receiver: 'response', message: 'body', arguments: { size: 0 } }
              } do
      replace_with 'response.parsed_body'
    end
  end
end
