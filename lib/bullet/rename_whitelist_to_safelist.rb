# frozen_string_literal: true

Synvert::Rewriter.new('bullet', 'rename_whitelist_to_safelist') do
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
    {
      add_whitelist: 'add_safelist',
      delete_whitelist: 'delete_safelist',
      get_whitelist_associations: 'get_safelist_associations',
      reset_whitelist: 'reset_safelist',
      clear_whitelist: 'clear_safelist'
    }.each do |old_method, new_method|
      with_node type: 'send', receiver: 'Bullet', message: old_method do
        replace :message, with: new_method
      end
    end
  end
end