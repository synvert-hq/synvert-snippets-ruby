# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_3_1_to_3_2' do
  description 'It upgrades rails from 3.1 to 3.2.'

  add_snippet 'rails', 'convert_configs_3_1_to_3_2'
  add_snippet 'rails', 'convert_constants_3_1_to_3_2'
  add_snippet 'rails', 'fix_model_3_2_deprecations'

  within_files 'vendor/plugins' do
    warn 'Rails::Plugin is deprecated and will be removed in Rails 4.0. Instead of adding plugins to vendor/plugins use gems or bundler with path or git dependencies.'
  end
end
