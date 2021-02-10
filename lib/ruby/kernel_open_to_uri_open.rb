# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'kernel_open_to_uri_open' do
  description <<~EOF
    It converts Kernel#open to URI.open
    
        open('http://test.com')
        =>
        URI.open('http://test.com')
  EOF

  within_files '**/*.rb' do
    # open('http://test.com')
    # =>
    # URI.open('http://test.com')
    with_node type: 'send', receiver: nil, message: 'open' do
      replace_with 'URI.open({{arguments}})'
    end
  end
end
