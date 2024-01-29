# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_6_1_to_7_0' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It upgrades rails 6.1 to 7.0
  EOS

  add_snippet 'rails', 'convert_configs_6_1_to_7_0'
end
