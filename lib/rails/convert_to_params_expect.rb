# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_to_params_expect' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts `params.require(...).permit(...)` to `params.expect(...)`.

    ```ruby
    params.require(:post).permit(:title, :summary, categories: [:name])
    ```

    =>

    ```ruby
    params.expect(post: [:title, :summary, categories: [[:name]]])
    ```
  EOS

  if_gem 'actionpack', '>= 8.0'

  within_files Synvert::RAILS_CONTROLLER_FILES do
    with_node node_type: 'call_node',
              receiver: { node_type: 'call_node', receiver: 'params', name: 'require' },
              name: 'permit' do
      goto_node :arguments do
        with_node node_type: 'array_node' do
          wrap prefix: '[', suffix: ']'
        end
      end
    end
  end

  within_files Synvert::RAILS_CONTROLLER_FILES do
    with_node node_type: 'call_node',
              receiver: { node_type: 'call_node', receiver: 'params', name: 'require' },
              name: 'permit' do
      replace_with 'params.expect({{receiver.arguments.arguments.first.value.to_s}}: [{{arguments}}])'
    end
  end
end
