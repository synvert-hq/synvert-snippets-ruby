# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_5_0_to_5_1' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts rails configs from 5.0 to 5.1.

    It sets `config.load_defaults 5.1` in config/application.rb.
  EOS

  if_gem 'rails', '~> 5.1.0'

  call_helper 'rails/set_load_defaults', rails_version: '5.1'
end
