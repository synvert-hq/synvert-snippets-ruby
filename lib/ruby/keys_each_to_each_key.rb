# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'keys_each_to_each_key' do
  description <<~EOF
    It convert Hash#keys.each to Hash#each_key
    
        params.keys.each {}
        =>
        params.each_key {}
  EOF

  within_files '**/*.rb' do
    # params.keys.each {}
    # =>
    # params.each_key {}
    with_node type: 'send', message: 'each', receiver: { type: 'send', message: 'keys' } do
      replace_with '{{receiver.receiver}}.each_key'
    end
  end
end
