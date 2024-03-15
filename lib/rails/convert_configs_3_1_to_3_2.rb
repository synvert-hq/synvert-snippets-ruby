# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_3_1_to_3_2' do
  configure(parser: Synvert::PRISM_PARSER)

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

  if_gem 'rails', '~> 3.2.0'

  within_file 'config/environments/development.rb' do
    # prepend config.active_record.auto_explain_threshold_in_seconds = 0.5
    unless_exist_node node_type: 'call_node',
                      receiver: {
                        node_type: 'call_node',
                        receiver: 'config',
                        name: 'active_record'
                      },
                      name: 'auto_explain_threshold_in_seconds=' do
      prepend 'config.active_record.auto_explain_threshold_in_seconds = 0.5'
    end
  end

  within_files 'config/environments/{development,test}.rb' do
    # prepend config.active_record.mass_assignment_sanitizer = :strict
    unless_exist_node node_type: 'call_node',
                      receiver: {
                        node_type: 'call_node',
                        receiver: 'config',
                        name: 'active_record'
                      },
                      name: 'mass_assignment_sanitizer=' do
      prepend 'config.active_record.mass_assignment_sanitizer = :strict'
    end
  end
end
