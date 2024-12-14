# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_7_1_to_7_2' do
  description 'It upgrades rails 7.1 to 7.2.'

  add_snippet 'rails', 'convert_configs_7_1_to_7_2'
  add_snippet 'rails', 'new_enum_syntax'
end
