# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_5_1_to_5_2' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It upgrades rails 5.1 to 5.2

    1. it replaces `dalli_store` with `mem_cache_store`
  EOS

  add_snippet 'rails', 'active_record_association_call_use_keyword_arguments'
  add_snippet 'rails', 'test_request_methods_use_keyword_arguments'

  if_gem 'rails', '>= 5.2'

  call_helper 'rails/set_load_defaults', rails_version: '5.2'

  within_file 'config/application.rb' do
    # dalli_store => mem_cache_store
    with_node node_type: 'sym', to_value: 'dalli_store' do
      replace_with ':mem_cache_store'
    end
  end
end
