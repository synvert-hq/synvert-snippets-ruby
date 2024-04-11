# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'rename_errors_keys_to_attribute_names' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It renames `errors#keys` to `erros#attribute_names`
  EOS

  if_gem 'rails', '>= 6.1'

  within_files Synvert::RAILS_MODEL_FILES do
    with_node node_type: 'call_node',
              receiver: { node_type: 'call_node', name: 'errors', arguments: nil },
              name: 'keys',
              arguments: nil do
      replace :message, with: 'attribute_names'
    end
  end
end
