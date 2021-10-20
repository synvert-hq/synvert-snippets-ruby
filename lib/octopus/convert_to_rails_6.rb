# frozen_string_literal: true

Synvert::Rewriter.new 'octopus', 'convert_to_rails_6' do
  description <<~EOS
    Convert octopus to rails 6 multi databases.

    ```ruby
    messages = current_user.using(:slave).messages
    ```

    =>

    ```ruby
    messages = ActiveRecord::Base.connected_to(role: :reading) do
      current_user.messages
    end
    ```
  EOS

  helper_method :wrap_ar_connected_to do |indent|
    using_node = false
    with_node type: 'send', message: 'using', arguments: [:slave] do
      using_node = true
    end
    wrap with: 'ActiveRecord::Base.connected_to(role: :reading) do', indent: indent if using_node
  end

  within_files 'app/**/*.rb' do
    # self.using(:slave).messages
    # =>
    # ActiveRecord::Base.connected_to(role: :reading) do
    #   self.using(:slave).messages
    # end
    %w[ivasgn lvasgn or_asgn].each do |type|
      with_node type: type do
        indent = node.column
        goto_node :right_value do
          wrap_ar_connected_to(indent)
        end
      end
    end

    %w[def defs].each do |type|
      with_node type: type do
        goto_node :body do
          with_direct_node type: 'send' do
            indent = node.column
            wrap_ar_connected_to(indent)
          end
        end
      end
    end
  end

  within_files 'app/**/*.rb' do
    # ActiveRecord::Base.connected_to(role: :reading) do
    #   self.using(:slave).messages
    # end
    # =>
    # ActiveRecord::Base.connected_to(role: :reading) do
    #   self.messages
    # end
    with_node type: 'block',
              caller: {
                type: 'send',
                receiver: 'ActiveRecord::Base',
                message: 'connected_to',
                arguments: {
                  first: {
                    type: 'hash',
                    role_value: :reading
                  }
                }
              } do
      with_node type: 'send', receiver: { not: nil }, message: 'using', arguments: [:slave] do
        delete :dot, :message, :parentheses, :arguments
      end
      with_node type: 'send', receiver: { type: 'send', receiver: nil, message: 'using', arguments: [:slave] } do
        delete :dot, 'receiver.message', 'receiver.parentheses', 'receiver.arguments'
      end
    end
  end
end
