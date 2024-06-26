# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_3_0_to_3_1' do
  description 'It upgrades rails from 3.0 to 3.1.'

  add_snippet 'rails', 'convert_configs_3_0_to_3_1'
  add_snippet 'rails', 'use_migrations_instance_methods'
end
