# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_model_lambda_scope' do
  description <<~EOS
    It converts activerecord scope to lambda scope.

    ```ruby
    class Post < ActiveRecord::Base
      scope :active, where(active: true)
      scope :published, Proc.new { where(published: true) }
      scope :by_user, proc { |user_id| where(user_id: user_id) }
      default_scope order("updated_at DESC")
      default_scope { order("created_at DESC") }
    end
    ```

    =>

    ```ruby
    class Post < ActiveRecord::Base
      scope :active, -> { where(active: true) }
      scope :published, -> { where(published: true) }
      scope :by_user, ->(user_id) { where(user_id: user_id) }
      default_scope -> { order("updated_at DESC") }
      default_scope -> { order("created_at DESC") }
    end
    ```
  EOS

  if_gem 'activerecord', '>= 4.0'

  within_files Synvert::RAILS_MODEL_FILES do
    # scope :active, where(active: true) => scope :active, -> { where(active: true) }
    with_node type: 'send', receiver: nil, message: 'scope' do
      with_node type: 'block', caller: { type: 'send', receiver: nil, message: 'proc' } do
        if node.arguments.length > 0
          replace_with '->({{arguments}}) { {{body}} }'
        else
          replace_with '-> { {{body}} }'
        end
      end

      with_node type: 'block', caller: { type: 'send', receiver: 'Proc', message: 'new' } do
        if node.arguments.length > 0
          replace_with '->({{arguments}}) { {{body}} }'
        else
          replace_with '-> { {{body}} }'
        end
      end

      unless_exist_node type: 'block', caller: { type: 'send', message: 'lambda' } do
        replace_with 'scope {{arguments.first}}, -> { {{arguments.last}} }'
      end
    end

    # default_scope order("updated_at DESC") => default_scope -> { order("updated_at DESC") }
    with_node type: 'send', receiver: nil, message: 'default_scope' do
      unless_exist_node type: 'block', caller: { type: 'send', message: 'lambda' } do
        replace_with 'default_scope -> { {{arguments.last}} }'
      end
    end

    # default_scope { order("updated_at DESC") } => default_scope -> { order("updated_at DESC") }
    with_node type: 'block', caller: { type: 'send', receiver: nil, message: 'default_scope' } do
      replace_with 'default_scope -> { {{body}} }'
    end
  end
end
