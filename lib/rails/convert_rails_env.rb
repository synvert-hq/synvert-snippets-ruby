# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_rails_env' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts RAILS_ENV to Rails.env.

    ```ruby
    RAILS_ENV
    \"\#{RAILS_ENV}\"
    RAILS_ENV == 'development'
    'development' == RAILS_ENV
    RAILS_ENV != 'development'
    'development' != RAILS_ENV
    ```

    =>

    ```ruby
    Rails.env
    \"\#{Rails.env}\"
    Rails.env.development?
    Rails.env.development?
    !Rails.env.development?
    !Rails.env.development?
    ```
  EOS

  if_gem 'rails', '>= 2.3'

  within_files Synvert::ALL_RUBY_FILES do
    # RAILS_ENV == 'test'
    # =>
    # Rails.env == 'test'
    with_node node_type: 'const', to_source: 'RAILS_ENV' do
      replace_with 'Rails.env'
    end
    with_node node_type: 'const', to_source: '::RAILS_ENV' do
      replace_with 'Rails.env'
    end
  end

  within_files Synvert::ALL_RUBY_FILES do
    # Rails.env == 'test'
    # =>
    # Rails.env.test?
    with_node node_type: 'send', receiver: 'Rails.env', message: '==', arguments: { size: 1 } do
      env = node.arguments.first.to_value
      replace_with "Rails.env.#{env}?"
    end

    # 'development' == Rails.env
    # =>
    # Rails.env.development?
    with_node node_type: 'send', arguments: { first: 'Rails.env' }, message: '==' do
      env = node.receiver.to_value
      replace_with "Rails.env.#{env}?"
    end

    # Rails.env != 'test'
    # =>
    # !Rails.env.test?
    with_node node_type: 'send', receiver: 'Rails.env', message: '!=', arguments: { size: 1 } do
      env = node.arguments.first.to_value
      replace_with "!Rails.env.#{env}?"
    end

    # 'development' != Rails.env
    # =>
    # !Rails.env.development?
    with_node node_type: 'send', arguments: { first: 'Rails.env' }, message: '!=' do
      env = node.receiver.to_value
      replace_with "!Rails.env.#{env}?"
    end
  end
end
