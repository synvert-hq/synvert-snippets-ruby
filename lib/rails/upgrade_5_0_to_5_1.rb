# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_5_0_to_5_1' do
  description <<-EOF
1. it replaces HashWithIndifferentAccess with ActiveSupport::HashWithIndifferentAccess.

2. it replaces Rails.application.config.secrets[:smtp_settings]["address"] with
   Rails.application.config.secrets[:smtp_settings][:address]
  EOF

  within_files '**/*.rb' do
    # HashWithIndifferentAccess
    # =>
    # ActiveSupport::HashWithIndifferentAccess
    with_node type: 'const', to_source: 'HashWithIndifferentAccess' do
      replace_with 'ActiveSupport::HashWithIndifferentAccess'
    end

    # Rails.appplication.config.secrets[:smtp_settings]["address"]
    # =>
    # Rails.appplication.config.secrets[:smtp_settings][:address]
    with_node type: 'send', message: '[]', arguments: { first: { type: 'str' } } do
      if :send == node.receiver.type && :[] == node.receiver.message &&
           'Rails.application.config.secrets' == node.receiver.receiver.to_source
        replace_with '{{receiver}}[:{{arguments.first.to_value.to_sym}}]'
      end
    end
  end
end
