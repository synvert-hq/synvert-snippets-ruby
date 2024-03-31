# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'add_active_record_migration_rails_version' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It adds default ActiveRecord::Migration rails version.

    ```ruby
    class CreateUsers < ActiveRecord::Migration
    end
    ```

    =>

    ```ruby
    class CreateUsers < ActiveRecord::Migration[4.2]
    end
    ```
  EOS

  if_gem 'rails', '>= 5.0'

  within_files Synvert::RAILS_MIGRATION_FILES do
    with_node node_type: 'class_node', superclass: 'ActiveRecord::Migration' do
      replace :superclass, with: '{{superclass}}[4.2]'
    end
  end
end
