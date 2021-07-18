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

  within_files 'app/**/*.rb' do
    %w[def defs ivasgn lvasgn or_asgn].each do |type|
      with_node type: type do
        with_direct_node({}) do
          using_node = nil
          with_node type: 'send', message: 'using', arguments: [:slave] do
            using_node = node
            delete :dot, :message, :parentheses, :arguments
          end
          if using_node
            indent = ' ' * node.indent
            goto_node :right_value do
              insert "ActiveRecord::Base.connected_to(role: :reading) do\n#{indent}  ", at: 'beginning'
              insert "\n#{indent}end", at: 'end'
            end
          end
        end
      end
    end
  end
end
