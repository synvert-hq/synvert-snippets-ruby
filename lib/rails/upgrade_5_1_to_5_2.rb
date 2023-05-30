# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_5_1_to_5_2' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It upgrades rails 5.1 to 5.2

    1. it replaces `dalli_store` with `mem_cache_store`
  EOS

  if_gem 'rails', '>= 5.2'

  within_file 'config/application.rb' do
    # dalli_store => mem_cache_store
    with_node node_type: 'sym', to_value: 'dalli_store' do
      replace_with ':mem_cache_store'
    end
  end
end
