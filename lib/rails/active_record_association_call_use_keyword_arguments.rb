# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'active_record_association_call_use_keyword_arguments' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts active_record association call to use keyword arguments

    ```ruby
    has_many :comments, { :dependent => :destroy }
    ```

    =>

    ```ruby
    has_many :comments, :dependent => :destroy
    ```
  EOS

  if_ruby '2.7'
  if_gem 'rails', '>= 5.2'

  association_call_methods = %i[belongs_to has_one has_many has_and_belongs_to_many]

  within_files Synvert::RAILS_MODEL_FILES do
    with_node node_type: 'call_node',
              receiver: nil,
              message: { in: association_call_methods },
              arguments: { node_type: 'arguments_node', arguments: { size: 2, last: { node_type: 'hash_node' } } } do
      replace 'arguments.arguments.-1', with: '{{arguments.arguments.-1.elements}}'
    end
  end
end
