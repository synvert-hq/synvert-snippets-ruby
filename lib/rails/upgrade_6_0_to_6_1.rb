# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_6_0_to_6_1' do
  description 'It upgrades rails 6.0 to 6.1.'

  add_snippet 'rails', 'convert_configs_6_0_to_6_1'
  add_snippet 'rails', 'convert_update_attributes_to_update'
  add_snippet 'rails', 'deprecate_errors_as_hash'
  add_snippet 'rails', 'rename_errors_keys_to_attribute_names'
  add_snippet 'rails', 'use_active_storage_image_processing_macros'
end
