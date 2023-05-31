# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_6_0_to_6_1' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It upgrades rails 6.0 to 6.1
  EOS

  add_snippet 'rails', 'convert_update_attributes_to_update'

  if_gem 'rails', '>= 6.1'

  call_helper 'rails/set_load_defaults', options: { rails_version: '6.1' }
end
