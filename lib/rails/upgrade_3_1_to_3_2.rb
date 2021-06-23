# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_3_1_to_3_2' do
  description <<~EOS
    It upgrades rails from 3.1 to 3.2.

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

  add_snippet 'rails', 'fix_controller_3_2_deprecations'
  add_snippet 'rails', 'fix_model_3_2_deprecations'

  if_gem 'rails', '>= 3.2'

  within_file 'config/environments/development.rb' do
    # prepend config.active_record.auto_explain_threshold_in_seconds = 0.5
    unless_exist_node type: 'send',
                      receiver: {
                        type: 'send',
                        receiver: {
                          type: 'send',
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
    unless_exist_node type: 'send',
                      receiver: {
                        type: 'send',
                        receiver: {
                          type: 'send',
                          message: 'config'
                        },
                        message: 'active_record'
                      },
                      message: 'mass_assignment_sanitizer=' do
      prepend 'config.active_record.mass_assignment_sanitizer = :strict'
    end
  end

  within_files 'vendor/plugins' do
    warn 'Rails::Plugin is deprecated and will be removed in Rails 4.0. Instead of adding plugins to vendor/plugins use gems or bundler with path or git dependencies.'
  end

  todo <<~EOS
    Make the following changes to your Gemfile.

        group :assets do
          gem 'sass-rails',   '~> 3.2.3'
          gem 'coffee-rails', '~> 3.2.1'
          gem 'uglifier',     '>= 1.0.3'
        end
  EOS
end
