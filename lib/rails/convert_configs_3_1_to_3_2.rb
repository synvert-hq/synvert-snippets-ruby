# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_3_1_to_3_2' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It upgrades rails configs from 3.1 to 3.2.

    1. it inserts new configs in config/environments/development.rb.

    ```ruby
    config.active_record.mass_assignment_sanitizer = :strict
    config.active_record.auto_explain_threshold_in_seconds = 0.5
    ```

    2. it inserts new configs in config/environments/test.rb.

    ```ruby
    config.active_record.mass_assignment_sanitizer = :strict
    ```
  EOS

  if_gem 'rails', '>= 3.2'

  within_file 'config/environments/development.rb' do
    # prepend config.active_record.auto_explain_threshold_in_seconds = 0.5
    unless_exist_node node_type: 'send',
                      receiver: {
                        node_type: 'send',
                        receiver: {
                          node_type: 'send',
                          message: 'config'
                        },
                        message: 'active_record'
                      },
                      message: 'auto_explain_threshold_in_seconds=' do
      prepend 'config.active_record.auto_explain_threshold_in_seconds = 0.5'
    end
  end

  within_files 'config/environments/{development,test}.rb' do
    # prepend config.active_record.mass_assignment_sanitizer = :strict
    unless_exist_node node_type: 'send',
                      receiver: {
                        node_type: 'send',
                        receiver: {
                          node_type: 'send',
                          message: 'config'
                        },
                        message: 'active_record'
                      },
                      message: 'mass_assignment_sanitizer=' do
      prepend 'config.active_record.mass_assignment_sanitizer = :strict'
    end
  end
end
