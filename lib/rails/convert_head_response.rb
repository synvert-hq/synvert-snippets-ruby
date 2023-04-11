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

  if_gem 'actionpack', '>= 5.0'

  within_file Synvert::RAILS_CONTROLLER_FILES do
    # render nothing: true
    # render nothing: true, status: :created
    # =>
    # head :ok
    # head :created
    with_node node_type: 'send',
              receiver: nil,
              message: 'render',
              arguments: {
                size: 1,
                first: {
                  node_type: 'hash',
                  nothing_value: true
                }
              } do
      replace :message, with: 'head'
      goto_node 'arguments.0' do
        with_node node_type: 'hash', status_value: nil do
          replace_with ':ok'
        end
        with_node node_type: 'hash', status_value: { not: nil } do
          replace_with '{{status_source}}'
        end
      end
    end

    # head status: 406
    # head location: '/foo'
    # =>
    # head 406
    # head :ok, location: '/foo'
    with_node node_type: 'send', receiver: nil, message: 'head', arguments: { size: 1, first: { node_type: 'hash' } } do
      goto_node 'arguments.0' do
        with_node node_type: 'hash', location_value: { not: nil } do
          replace_with ':ok, {{to_source}}'
        end
        with_node node_type: 'hash', status_value: { not: nil } do
          replace_with '{{status_source}}'
        end
      end
    end
  end
end
