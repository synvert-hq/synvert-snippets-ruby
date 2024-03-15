# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_4_1_to_4_2' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts rails configs from 4.1 to 4.2

    1. it replaces `config.serve_static_assets = ...` with `config.serve_static_files = ...` in config files.

    2. it inserts `config.active_record.raise_in_transactional_callbacks = true` in config/application.rb
  EOS

  if_gem 'rails', '~> 4.2.0'

  within_files 'config/environments/*.rb' do
    # config.serve_static_assets = false
    # =>
    # config.serve_static_files = false
    with_node node_type: 'call_node', name: 'serve_static_assets=' do
      replace :message, with: 'serve_static_files'
    end
  end

  within_file 'config/application.rb' do
    # append config.active_record.raise_in_transactional_callbacks = true
    with_node node_type: 'class_node', superclass: 'Rails::Application' do
      unless_exist_node node_type: 'call_node',
                        receiver: {
                          node_type: 'call_node',
                          receiver: 'config',
                          name: 'active_record'
                        },
                        name: 'raise_in_transactional_callbacks=' do
        append 'config.active_record.raise_in_transactional_callbacks = true'
      end
    end
  end
end
