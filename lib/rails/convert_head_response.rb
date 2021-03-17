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

  within_file 'app/controllers/**/*.rb' do
    # render nothing: true
    # render nothing: true, status: :created
    # =>
    # head :ok
    # head :created
    with_node type: 'send', receiver: nil, message: 'render', arguments: { size: 1, first: { type: 'hash' } } do
      hash_node = node.arguments.first
      if hash_node.key?(:nothing) && hash_node.hash_value(:nothing).to_value == true
        status_value = hash_node.hash_value(:status) ? hash_node.hash_value(:status).to_source : ':ok'
        replace_with "head #{status_value}"
      end
    end

    # head status: 406
    # head location: '/foo'
    # =>
    # head 406
    # head :ok, location: '/foo'
    with_node type: 'send', receiver: nil, message: 'head', arguments: { size: 1, first: { type: 'hash' } } do
      if node.arguments.first.key? :status
        replace_with 'head {{arguments.first.values.first}}'
      else
        replace_with 'head :ok, {{arguments}}'
      end
    end
  end
end
