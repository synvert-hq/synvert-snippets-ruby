# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'rename_errors_keys_to_attribute_names' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It renames `errors#keys` to `erros#attribute_names`
  EOS

  if_gem 'rails', '>= 6.1'

  within_files Synvert::RAILS_MODEL_FILES do
    with_node node_type: 'send',
              receiver: { node_type: 'send', message: 'errors', arguments: { size: 0 } },
              message: 'keys',
              arguments: { size: 0 } do
      replace :message, with: 'attribute_names'
    end
  end
end
