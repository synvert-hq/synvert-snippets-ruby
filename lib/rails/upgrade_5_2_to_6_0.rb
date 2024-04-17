# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_5_2_to_6_0' do
  description 'It upgrades rails 5.2 to 6.0.'

  add_snippet 'rails', 'convert_configs_5_2_to_6_0'
  add_snippet 'rails', 'convert_update_attributes_to_update'
  add_snippet 'rails', 'prefer_nor_conditions'
end
