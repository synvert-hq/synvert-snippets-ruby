# frozen_string_literal: true

Synvert::Rewriter.new('bullet', 'rename_whitelist_to_safelist') do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It renames bullet whitelist to safelist.

    ```ruby
    Bullet.add_whitelist(type: :n_plus_one_query, class_name: 'Klass', association: :department)
    Bullet.delete_whitelist(type: :n_plus_one_query, class_name: 'Klass', association: :team)
    Bullet.get_whitelist_associations(:n_plus_one_query, 'Klass')
    Bullet.reset_whitelist
    Bullet.clear_whitelist
    ```

    =>

    ```ruby
    Bullet.add_safelist(type: :n_plus_one_query, class_name: 'Klass', association: :department)
    Bullet.delete_safelist(type: :n_plus_one_query, class_name: 'Klass', association: :team)
    Bullet.get_safelist_associations(:n_plus_one_query, 'Klass')
    Bullet.reset_safelist
    Bullet.clear_safelist
    ```
  EOS

  if_gem 'bullet', '>= 6.1.5'

  within_files Synvert::ALL_RUBY_FILES do
    bullet_methods = {
      add_whitelist: 'add_safelist',
      delete_whitelist: 'delete_safelist',
      get_whitelist_associations: 'get_safelist_associations',
      reset_whitelist: 'reset_safelist',
      clear_whitelist: 'clear_safelist'
    }

    find_node ".send[receiver=Bullet][message IN (#{bullet_methods.keys.join(' ')})]" do
      replace :message, with: bullet_methods[node.message.to_sym]
    end
  end
end
