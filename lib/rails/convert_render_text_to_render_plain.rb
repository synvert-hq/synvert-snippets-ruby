# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_render_text_to_render_plain' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts `render :text` to `render :plain`

    ```ruby
    render text: 'OK'
    ```

    =>

    ```ruby
    render plain: 'OK'
    ```
  EOS

  if_gem 'actionpack', '>= 5.0'

  within_files Synvert::RAILS_CONTROLLER_FILES do
    with_node node_type: 'send',
              receiver: nil,
              message: 'render',
              arguments: { size: 1, first: { node_type: 'hash' } } do
      with_node node_type: 'hash' do
        with_node node_type: :sym, to_source: 'text' do
          replace_with 'plain'
        end
        with_node node_type: :sym, to_source: ':text' do
          replace_with ':plain'
        end
      end
    end
  end
end
