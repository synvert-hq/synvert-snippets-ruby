Synvert::Rewriter.new 'ruby', 'fast_syntax' do
  description <<-EOF
Use ruby fast syntax, it calls snippets

    avoid_parallel_assignment
    block_to_yield
    fetch_use_block_default
    gsub_to_tr
    map_and_flatten_to_flat_map
    merge_to_square_brackets
    use_symbol_to_proc

    reference: https://speakerdeck.com/sferik/writing-fast-ruby
  EOF

  add_snippet 'ruby', 'avoid_parallel_assignment'
  add_snippet 'ruby', 'block_to_yield'
  add_snippet 'ruby', 'fetch_use_block_default'
  add_snippet 'ruby', 'gsub_to_tr'
  add_snippet 'ruby', 'map_and_flatten_to_flat_map'
  add_snippet 'ruby', 'merge_to_square_brackets'
  add_snippet 'ruby', 'use_symbol_to_proc'
end
