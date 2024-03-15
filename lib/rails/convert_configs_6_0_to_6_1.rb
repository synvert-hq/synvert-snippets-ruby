# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_6_0_to_6_1' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts rails configs from 6.0 to 6.1

    It sets `config.load_defaults 6.1` in config/application.rb.
  EOS

  if_gem 'rails', '~> 6.1.0'

  call_helper 'rails/set_load_defaults', rails_version: '6.1'
end
