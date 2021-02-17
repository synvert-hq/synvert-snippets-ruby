# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_update_attributes_to_update' do
  description <<~EOS
    It converts .update_attributes to .update

    ```ruby
    user.update_attributes(title: 'new')
    user.update_attributes!(title: 'new')
    ```

    =>

    ```ruby
    user.update(title: 'new')
    user.update!(title: 'new')
    ```
  EOS

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