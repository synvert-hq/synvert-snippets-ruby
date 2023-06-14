# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_5_2_to_6_0' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It upgrades rails 5.2 to 6.0
  EOS

  add_snippet 'rails', 'convert_update_attributes_to_update'

  if_gem 'rails', '>= 6.0'

  call_helper 'rails/set_load_defaults', rails_version: '6.0'
end
