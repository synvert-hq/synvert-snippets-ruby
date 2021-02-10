# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_render_nothing_true_to_head_ok' do
  description <<~EOF
    It replaces render nothing: true with head :ok in controller files.
    
        render nothing: true
        =>
        head :ok
  EOF

  within_file 'app/controllers/**/*.rb' do
    # render nothing: true
    # render nothing: true, status: :created
    # =>
    # head :ok
    # head :created
    with_node type: 'send', receiver: nil, message: 'render', arguments: { size: 1, first: { type: 'hash' } } do
      hash_node = node.arguments.first
      if hash_node.has_key?(:nothing) && hash_node.hash_value(:nothing).to_value == true
        status_value = hash_node.hash_value(:status) ? hash_node.hash_value(:status).to_source : ':ok'
        replace_with "head #{status_value}"
      end
    end
  end
end
