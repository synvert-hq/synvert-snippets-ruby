# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_5_2_to_6_0' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts rails configs from 5.2 to 6.0

    It sets `config.load_defaults 6.0` in config/application.rb.
  EOS

  if_gem 'rails', '~> 6.0.0'

  call_helper 'rails/set_load_defaults', rails_version: '6.0'
end
