# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_6_1_to_7_0' do
  description 'It upgrades rails 6.1 to 7.0.'

  add_snippet 'rails', 'convert_configs_6_1_to_7_0'
  add_snippet 'rails', 'deprecate_errors_as_hash'
  add_snippet 'rails', 'remove_active_support_dependencies_private_api'
  add_snippet 'rails', 'update_active_storage_variant_argument'
  add_snippet 'rails', 'explicitly-render-with-formats'
end
