# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_7_2_to_8_0' do
  description 'It upgrades rails 7.2 to 8.0.'

  add_snippet 'rails', 'convert_configs_7_2_to_8_0'
  add_snippet 'rails', 'new_enum_syntax'
  add_snippet 'rails', 'convert_to_params_expect'
end
