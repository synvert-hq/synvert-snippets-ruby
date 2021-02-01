
Synvert::Rewriter.new 'rails', 'convert_render_nothing_true_to_head_ok' do
  description <<-EOF
    it replaces render nothing: true with head :ok in controller files.
  EOF

  within_file 'app/controllers/**/*.rb' do
    # render nothing: true
    # =>
    # head :ok
    with_node type: 'send', receiver: nil, message: 'render', arguments: { size: 1, first: { type: 'hash', keys: ['nothing'], values: [true] } } do
      replace_with 'head :ok'
    end
  end
end