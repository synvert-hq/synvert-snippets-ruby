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

  helper_method :convert_using_to_connected_to do |indent|
    using_node = false
    with_node type: 'send', receiver: { not: nil }, message: 'using', arguments: [:slave] do
      using_node = true
      delete :dot, :message, :parentheses, :arguments
    end
    with_node type: 'send', receiver: { type: 'send', receiver: nil, message: 'using', arguments: [:slave] } do
      using_node = true
      goto_node :receiver do
        delete :message, :parentheses, :arguments
      end
      delete :dot
    end
    if using_node
      insert "ActiveRecord::Base.connected_to(role: :reading) do\n#{indent}  ", at: 'beginning'
      insert "\n#{indent}end", at: 'end'
    end
  end

  within_files 'app/**/*.rb' do
    %w[ivasgn lvasgn or_asgn].each do |type|
      with_node type: type do
        indent = ' ' * node.indent
        goto_node :right_value do
          convert_using_to_connected_to(indent)
        end
      end
    end

    %w[def defs].each do |type|
      with_node type: type do
        goto_node :body do
          with_direct_node type: 'send' do
            indent = ' ' * node.indent
            convert_using_to_connected_to(indent)
          end
        end
      end
    end
  end
end
