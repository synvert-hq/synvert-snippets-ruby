# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_7_0_to_7_1' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts rails configs from 7.0 to 7.1

    1. it sets `config.load_defaults 7.1` in config/application.rb.

    2. it replaces `config.action_dispatch.show_exceptions = true` with `config.action_dispatch.show_exceptions = :all`,
        and `config.action_dispatch.show_exceptions = false` with `config.action_dispatch.show_exceptions = :none`.
  EOS

  if_gem 'rails', '~> 7.1.0'

  call_helper 'rails/set_load_defaults', rails_version: '7.1'

  within_files 'config/environments/*.rb' do
    with_node node_type: 'call_node',
              receiver: { node_type: 'call_node', receiver: 'config', name: 'action_dispatch' },
              name: 'show_exceptions=',
              arguments: { node_type: 'arguments_node', arguments: { size: 1, first: true } } do
      replace 'arguments.arguments', with: ':all'
    end

    with_node node_type: 'call_node',
              receiver: { node_type: 'call_node', receiver: 'config', name: 'action_dispatch' },
              name: 'show_exceptions=',
              arguments: { node_type: 'arguments_node', arguments: { size: 1, first: false } } do
      replace 'arguments.arguments', with: ':none'
    end
  end
end
