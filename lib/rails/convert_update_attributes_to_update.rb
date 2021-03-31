# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_update_attributes_to_update' do
  description <<~EOS
    It converts `.update_attributes` to `.update`

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

  if_gem 'activerecord', '>= 6.0'

  within_files '**/*.rb' do
    # user.update_attributes(title: 'new')
    # =>
    # user.update(title: 'new')
    with_node type: 'send', message: 'update_attributes' do
      replace :message, with: 'update'
    end

    # user.update_attributes!(title: 'new')
    # =>
    # user.update!(title: 'new')
    with_node type: 'send', message: 'update_attributes!' do
      replace :message, with: 'update!'
    end
  end
end
