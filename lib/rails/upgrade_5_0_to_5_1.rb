# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_5_0_to_5_1' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It upgrades rails 5.0 to 5.1.

    1. it replaces `HashWithIndifferentAccess` with `ActiveSupport::HashWithIndifferentAccess`.

    2. it replaces `Rails.application.config.secrets[:smtp_settings]["address"]` with
       `Rails.application.config.secrets[:smtp_settings][:address]`
  EOS

  add_snippet 'rails', 'application_secrets_use_symbol_keys'
  add_snippet 'rails', 'convert_active_record_dirty_5_0_to_5_1'
  add_snippet 'rails', 'convert_rails_constants_5_0_to_5_1'

  call_helper 'rails/set_load_defaults', rails_version: '5.1'
end
