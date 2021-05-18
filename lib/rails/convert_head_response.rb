# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_head_response' do
  description <<~EOS
    It replaces render head response in controller files.

    ```ruby
    render nothing: true
    render nothing: true, status: :created

    head status: 406
    head location: '/foo'
    ```

    =>

    ```ruby
    head :ok
    head :created

    head 406
    head :ok, location: '/foo'
    ```
  EOS

  if_gem 'actionpack', '5.0'

  within_file 'app/controllers/**/*.rb' do
    # render nothing: true
    # render nothing: true, status: :created
    # =>
    # head :ok
    # head :created
    with_node type: 'send',
              receiver: nil,
              message: 'render',
              arguments: {
                size: 1,
                first: {
                  type: 'hash',
                  nothing_value: 'true'
                }
              } do
      replace :message, with: 'head'
      goto_node :arguments, :first do
        with_node type: 'hash', nothing_value: 'true', status_value: nil do
          replace_with ':ok'
        end
        with_node type: 'hash', nothing_value: 'true', status_value: any_value do
          replace_with ':{{status_value}}'
        end
      end
    end

    # head status: 406
    # head location: '/foo'
    # =>
    # head 406
    # head :ok, location: '/foo'
    with_node type: 'send', receiver: nil, message: 'head', arguments: { size: 1, first: { type: 'hash' } } do
      goto_node :arguments, :first do
        with_node type: 'hash', location_value: any_value do
          replace_with ':ok, {{to_source}}'
        end
        with_node type: 'hash', status_value: any_value do
          replace_with '{{status_value}}'
        end
      end
    end
  end
end
