# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_4_1_to_4_2' do
  configure(parser: Synvert::PARSER_PARSER)

  description 'It upgrades rails from 4.1 to 4.2.'

  add_snippet 'rails', 'convert_configs_4_1_to_4_2'
end
