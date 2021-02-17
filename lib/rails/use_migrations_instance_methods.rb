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

  if_gem 'activerecord', { gte: '3.1.0' }

  within_files 'db/migrate/*.rb' do
    # def self.up => def up
    # def self.down => def down
    %w(up down).each do |name|
      with_node type: 'defs', name: name do
        new_code = <<~EOS
          def #{name}
              {{body}}
            end
        EOS
        replace_with new_code.strip, autoindent: false
      end
    end
  end
end
