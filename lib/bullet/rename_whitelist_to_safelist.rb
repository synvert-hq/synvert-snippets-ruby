Synvert::Rewriter.new('bullet', 'rename_whitelist_to_safelist') do
  within_files '**/*.rb' do
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
