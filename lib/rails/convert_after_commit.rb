# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_after_commit' do
  description <<~EOS
    It converts active_record after_commit.

    ```ruby
    after_commit :add_to_index_later, on: :create
    after_commit :update_in_index_later, on: :update
    after_commit :remove_from_index_later, on: :destroy
    ```
    =>

    ```ruby
    after_create_commit :add_to_index_later
    after_update_commit :update_in_index_later
    after_detroy_commit :remove_from_index_later
    ```
  EOS

  if_gem 'activerecord', '>= 5.0'

  within_files 'app/models/**/*.rb' do
    # after_commit :add_to_index_later, on: :create
    # after_commit :update_in_index_later, on: :update
    # after_commit :remove_from_index_later, on: :destroy
    # =>
    # after_create_commit :add_to_index_later
    # after_update_commit :update_in_index_later
    # after_detroy_commit :remove_from_index_later
    with_node type: 'send', receiver: nil, message: 'after_commit', arguments: { size: 2 } do
      options = node.arguments.last
      if options.key?(:on)
        other_options = options.children.reject { |pair_node| pair_node.key.to_value == :on }
        if other_options.empty?
          replace_with "after_#{options.hash_value(:on).to_value}_commit {{arguments.first.to_source}}"
        else
          replace_with "after_#{options.hash_value(:on).to_value}_commit {{arguments.first.to_source}}, #{other_options.map(&:to_source).join(', ')}"
        end
      end
    end
  end
end
