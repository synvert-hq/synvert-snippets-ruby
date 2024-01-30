# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_5_1_to_5_2' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts rails configs from 5.1 to 5.2

    1. it sets `config.load_defaults 5.2` in config/application.rb.

    2. it replaces `dalli_store` with `mem_cache_store`
  EOS

  if_gem 'rails', '~> 5.2.0'

  call_helper 'rails/set_load_defaults', rails_version: '5.2'

  within_file 'config/**/*.rb' do
    # dalli_store => mem_cache_store
    with_node node_type: 'sym', to_value: 'dalli_store' do
      replace_with ':mem_cache_store'
    end
  end
end
