# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_4_1_to_4_2' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It upgrades rails from 4.1 to 4.2

    1. it replaces `config.serve_static_assets = ...` with `config.serve_static_files = ...` in config files.

    2. it inserts `config.active_record.raise_in_transactional_callbacks = true` in config/application.rb
  EOS

  if_gem 'rails', '>= 4.2'

  within_files 'config/environments/*.rb' do
    # config.serve_static_assets = false
    # =>
    # config.serve_static_files = false
    with_node node_type: 'send', message: 'serve_static_assets=' do
      replace :message, with: 'serve_static_files ='
    end
  end

  within_file 'config/application.rb' do
    # append config.active_record.raise_in_transactional_callbacks = true
    with_node node_type: 'class', parent_class: 'Rails::Application' do
      unless_exist_node node_type: 'send',
                        receiver: {
                          node_type: 'send',
                          receiver: {
                            node_type: 'send',
                            message: 'config'
                          },
                          message: 'active_record'
                        },
                        message: 'raise_in_transactional_callbacks=' do
        append 'config.active_record.raise_in_transactional_callbacks = true'
      end
    end
  end
end
