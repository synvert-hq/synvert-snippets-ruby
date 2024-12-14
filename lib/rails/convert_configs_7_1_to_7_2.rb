# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_7_1_to_7_2' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts rails configs from 7.1 to 7.2

    1. it sets `config.load_defaults 7.2` in config/application.rb.
  EOS

  if_gem 'rails', '~> 7.2.0'

  call_helper 'rails/set_load_defaults', rails_version: '7.2'
end
