# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_7_0_to_7_1' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts rails configs from 7.0 to 7.1

    1. it sets `config.load_defaults 7.1` in config/application.rb.

    2. it replaces `config.action_dispatch.show_exceptions = true` with `config.action_dispatch.show_exceptions = :all`,
        and `config.action_dispatch.show_exceptions = false` with `config.action_dispatch.show_exceptions = :none`.
  EOS

  if_gem 'rails', '>= 7.1'

  call_helper 'rails/set_load_defaults', rails_version: '7.1'

  within_files 'config/environments/*.rb' do
    find_node '.send[receiver=.send[receiver=.send[receiver=nil][message=config][arguments.size=0]][message=action_dispatch][arguments.size=0]][message=show_exceptions=][arguments.size=1][arguments.0=true]' do
      replace :arguments, with: ':all'
    end

    find_node '.send[receiver=.send[receiver=.send[receiver=nil][message=config][arguments.size=0]][message=action_dispatch][arguments.size=0]][message=show_exceptions=][arguments.size=1][arguments.0=false]' do
      replace :arguments, with: ':none'
    end
  end
end