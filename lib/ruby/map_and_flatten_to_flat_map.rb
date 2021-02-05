Synvert::Rewriter.new 'ruby', 'map_and_flatten_to_flat_map' do
  description <<~EOF
    It converts map and flatten to flat_map
    
        enum.map do
          # do something
        end.flatten
        =>
        enum.flat_map do
          # do something
        end
  EOF

  within_files '**/*.rb' do
    # enum.map do
    #   # do something
    # end.flatten
    # =>
    # enum.flat_map do
    #   # do something
    # end
    with_node type: 'send', receiver: { type: 'block', caller: { type: 'send', message: 'map' } }, message: 'flatten' do
      replace_with "{{receiver.to_source.sub('.map', '.flat_map')}}"
    end
  end
end
