# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'add_active_record_migration_rails_version' do
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
    with_node type: 'class', parent_class: 'ActiveRecord::Migration' do
      replace :parent_class, with: 'ActiveRecord::Migration[4.2]'
    end
  end
end
