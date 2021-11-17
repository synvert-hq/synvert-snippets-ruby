# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'use_migrations_instance_methods' do
  description <<~EOS
    It uses instance methods rather than class methods in migrations.

    ```ruby
    def self.up
    end

    def self.down
    end
    ```

    =>

    ```ruby
    def up
    end

    def down
    end
    ```
  EOS

  if_gem 'activerecord', '>= 3.1'

  within_files Synvert::RAILS_MIGRATION_FILES do
    # def self.up => def up
    # def self.down => def down
    %w[up down].each do |name|
      with_node type: 'defs', name: name do
        delete :self, :dot
      end
    end
  end
end
