# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'rename_errors_keys_to_attribute_names' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It upgrades rails 6.0 to 6.1
  EOS

  if_gem 'rails', '>= 6.1'

  within_files Synvert::RAILS_MODEL_FILES do
    with_node node_type: 'send', receiver: { node_type: 'send', message: 'errors', arguments: { size: 0 } }, message: 'keys', arguments: { size: 0 } do
      replace :message, with: 'attribute_names'
    end
  end
end
