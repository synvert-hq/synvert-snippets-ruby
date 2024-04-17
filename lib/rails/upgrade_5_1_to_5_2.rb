# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_5_1_to_5_2' do
  description 'It upgrades rails 5.1 to 5.2.'

  add_snippet 'rails', 'convert_configs_5_1_to_5_2'
  add_snippet 'rails', 'active_record_association_call_use_keyword_arguments'
  add_snippet 'rails', 'test_request_methods_use_keyword_arguments'
end
