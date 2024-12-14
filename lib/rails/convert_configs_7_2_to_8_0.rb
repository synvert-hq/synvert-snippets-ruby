# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_7_2_to_8_0' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts rails configs from 7.1 to 8.0

    1. it sets `config.load_defaults 8.0` in config/application.rb.
  EOS

  if_gem 'rails', '~> 8.0.0'

  call_helper 'rails/set_load_defaults', rails_version: '8.0'
end
