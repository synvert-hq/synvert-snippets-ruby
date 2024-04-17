# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_4_0_to_4_1' do
  description <<~EOS
    It upgrades rails from 4.0 to 4.1.

    Warn return within inline callback blocks `before_save { return false }`
  EOS

  add_snippet 'rails', 'convert_configs_4_0_to_4_1'
  add_snippet 'rails', 'deprecate_active_record_migration_check_pending'
  add_snippet 'rails', 'deprecate_multi_json'
end
