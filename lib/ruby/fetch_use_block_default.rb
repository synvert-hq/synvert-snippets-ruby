Synvert::Rewriter.new 'ruby', 'fetch_use_block_default' do
  description <<-EOF
It converts Hash#fetch default param to use block style.

    {:rails => :club}.fetch(:rails, (0..9).to_a)
    =>
    {:rails => :club}.fetch(:rails) { (0..9).to_a }
  EOF

  within_files '**/*.rb' do
    # {:rails => :club}.fetch(:rails, (0..9).to_a)
    # =>
    # {:rails => :club}.fetch(:rails) { (0..9).to_a }
    with_node type: 'send', receiver: {not: nil}, message: 'fetch', arguments: {size: 2} do
      replace_with "{{receiver}}.fetch({{arguments.first}}) { {{arguments.last}} }"
    end
  end
end
