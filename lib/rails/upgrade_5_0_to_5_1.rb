# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_5_0_to_5_1' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It upgrades rails 5.0 to 5.1.

    1. it replaces `HashWithIndifferentAccess` with `ActiveSupport::HashWithIndifferentAccess`.

    2. it replaces `Rails.application.config.secrets[:smtp_settings]["address"]` with
       `Rails.application.config.secrets[:smtp_settings][:address]`
  EOS

  add_snippet 'rails', 'convert_active_record_dirty_5_0_to_5_1'

  if_gem 'rails', '>= 5.1'

  call_helper 'rails/set_load_defaults', rails_version: '5.1'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # HashWithIndifferentAccess
    # =>
    # ActiveSupport::HashWithIndifferentAccess
    with_node node_type: 'const', to_source: 'HashWithIndifferentAccess' do
      replace_with 'ActiveSupport::HashWithIndifferentAccess'
    end

    # Rails.appplication.config.secrets[:smtp_settings]["address"]
    # =>
    # Rails.appplication.config.secrets[:smtp_settings][:address]
    with_node node_type: 'send', message: '[]', arguments: { first: { node_type: 'str' } } do
      if :send == node.receiver.type && :[] == node.receiver.message &&
         'Rails.application.config.secrets' == node.receiver.receiver.to_source

        replace 'arguments.first', with: '{{arguments.first.to_symbol}}'
      end
    end
  end
end
