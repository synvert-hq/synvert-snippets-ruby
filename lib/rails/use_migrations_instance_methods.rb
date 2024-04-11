# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'use_migrations_instance_methods' do
  configure(parser: Synvert::PRISM_PARSER)

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
    with_node node_type: 'def_node', name: { in: ['up', 'down'] }, receiver: { node_type: 'self_node' } do
      delete :receiver, :operator
    end
  end
end
