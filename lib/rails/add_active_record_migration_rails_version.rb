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

  if_gem 'rails', { gte: '5.0.0' }

  within_files 'db/migrate/*.rb' do
    with_node type: 'class' do
      goto_node :parent_class do
        if node.to_source == 'ActiveRecord::Migration'
          replace_with 'ActiveRecord::Migration[4.2]'
        end
      end
    end
  end
end
