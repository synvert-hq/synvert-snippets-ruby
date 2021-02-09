Synvert::Rewriter.new 'rails', 'convert_update_attributes_to_update' do
  description <<-EOF
It converts .update_attributes to .update

    user.update_attributes(title: 'new')
    user.update_attributes!(title: 'new')
    =>
    user.update(title: 'new')
    user.update!(title: 'new')
  EOF

  within_files '**/*.rb' do
    # user.update_attributes(title: 'new')
    # =>
    # user.update(title: 'new')
    with_node type: 'send', message: 'update_attributes' do
      replace_with add_receiver_if_necessary('update({{arguments}})')
    end

    # user.update_attributes!(title: 'new')
    # =>
    # user.update!(title: 'new')
    with_node type: 'send', message: 'update_attributes!' do
      replace_with add_receiver_if_necessary('update!({{arguments}})')
    end
  end
end
