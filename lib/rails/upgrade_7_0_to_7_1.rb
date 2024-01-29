# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_7_0_to_7_1' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It upgrades rails 7.0 to 7.1
  EOS

  add_snippet 'rails', 'convert_configs_7_0_to_7_1'
end
