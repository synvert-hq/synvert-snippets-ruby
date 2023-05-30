# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'redirect_with_flash' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Fold flash setting into redirect_to.

    ```ruby
    flash[:notice] = "huzzah"
    redirect_to root_path
    ```

    =>

    ```ruby
    redirect_to root_path, notice: "huzzah"
    ```

    and

    ```ruby
    flash[:error] = "booo"
    redirect_to root_path
    ```

    =>

    ```ruby
    redirect_to root_path, flash: {error: "huzzah"}
    ```
  EOS

  within_file Synvert::RAILS_CONTROLLER_FILES do
    within_node node_type: 'def' do
      line = nil
      msg = nil
      remover_action = nil
      flash_type = nil
      with_node node_type: 'send', receiver: 'flash', arguments: { size: 2, last: { node_type: :str } } do
        line = node.line
        flash_type = node.arguments.first.to_source
        msg = node.arguments.last.to_source
        remover_action = NodeMutation::RemoveAction.new(node)
      end
      with_node node_type: 'send', receiver: nil, message: :redirect_to do
        if line.present? && node.line == line + 1
          add_action(remover_action)
          if [':notice', ':alert'].include?(flash_type)
            replace_with "{{message}} {{arguments}}, #{flash_type[1..-1]}: #{msg}"
          else
            replace_with "{{message}} {{arguments}}, flash: {#{flash_type[1..-1]}: #{msg}}"
          end
        end
      end
    end
  end
end
