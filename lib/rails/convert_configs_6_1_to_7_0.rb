# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_6_1_to_7_0' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts rails configs from 6.1 to 7.0

    It sets `config.load_defaults 7.0` in config/application.rb.

    It removes `config.autoloader = :classic` in config/application.rb.
  EOS

  if_gem 'rails', '~> 7.0.0'

  call_helper 'rails/set_load_defaults', rails_version: '7.0'

  within_files 'config/application.rb' do
    with_node node_type: 'call_node',
              receiver: { node_type: 'call_node', name: 'config' },
              name: 'autoloader=',
              arguments: { node_type: 'arguments_node', arguments: { size: { gt: 0 } } } do
      remove
    end
  end
end
