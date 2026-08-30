# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_7_0_to_7_1' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts rails configs from 7.0 to 7.1

    1. it sets `config.load_defaults 7.1` in config/application.rb.

    2. it replaces `config.action_dispatch.show_exceptions = true` with `config.action_dispatch.show_exceptions = :rescuable`,
        and `config.action_dispatch.show_exceptions = false` with `config.action_dispatch.show_exceptions = :none`.

    3. it replaces `config.cache_classes = true` with `config.enable_reloading = false`,
        and `config.cache_classes = false` with `config.enable_reloading = true`.
  EOS

  if_gem 'rails', '~> 7.1.0'

  call_helper 'rails/set_load_defaults', rails_version: '7.1'

  within_files 'config/environments/*.rb' do
    with_node node_type: 'call_node',
              receiver: { node_type: 'call_node', receiver: 'config', name: 'action_dispatch' },
              name: 'show_exceptions=',
              arguments: { node_type: 'arguments_node', arguments: { size: 1, first: { in: [true, false] } } } do
      replace 'arguments.arguments', with: node.arguments.arguments.first.to_value ? ':rescuable' : ':none'
    end

    with_node node_type: 'call_node',
              receiver: 'config',
              name: 'cache_classes=',
              arguments: { node_type: 'arguments_node', arguments: { size: 1, first: { in: [true, false] } } } do
      group do
        replace :message, with: 'enable_reloading'
        replace 'arguments.arguments', with: (!node.arguments.arguments.first.to_value).to_s
      end
    end
  end
end
