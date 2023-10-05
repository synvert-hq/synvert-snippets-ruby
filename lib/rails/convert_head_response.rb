# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_head_response' do
  configure(parser: Synvert::PARSER_PARSER)

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
      group do
        replace :message, with: 'head'
        if node.arguments.first.status_value.nil?
          replace 'arguments.0', with: ':ok'
        else
          replace 'arguments.0', with: '{{arguments.0.status_source}}'
        end
      end
    end

    # head status: 406
    # head location: '/foo'
    # =>
    # head 406
    # head :ok, location: '/foo'
    with_node node_type: 'send', receiver: nil, message: 'head', arguments: { size: 1, first: { node_type: 'hash' } } do
      if !node.arguments.first.location_value.nil?
        replace 'arguments.0', with: ':ok, {{arguments.0.to_source}}'
      elsif !node.arguments.first.status_value.nil?
        replace 'arguments.0', with: '{{arguments.0.status_source}}'
      end
    end
  end
end
