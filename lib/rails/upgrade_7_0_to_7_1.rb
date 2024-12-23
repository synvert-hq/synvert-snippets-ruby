# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_7_0_to_7_1' do
  description 'It upgrades rails 7.0 to 7.1.'

  add_snippet 'rails', 'convert_configs_7_0_to_7_1'
  add_snippet 'rails', 'new_enum_syntax'
end
