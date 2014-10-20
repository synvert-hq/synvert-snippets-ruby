Synvert::Rewriter.new 'ruby', 'fast_syntax' do
  description <<-EOF
Use ruby fast syntax, it calls snippets

    block_to_yield
    gsub_to_tr
    map_and_flatten_to_flat_map
    merge_to_square_brackets
    parallel_assignment_to_sequential_assignment
    use_symbol_to_proc

    reference: https://speakerdeck.com/sferik/writing-fast-ruby
  EOF

  add_snippet 'ruby', 'block_to_yield'
  add_snippet 'ruby', 'gsub_to_tr'
  add_snippet 'ruby', 'keys_each_to_each_key'
  add_snippet 'ruby', 'map_and_flatten_to_flat_map'
  add_snippet 'ruby', 'merge_to_square_brackets'
  add_snippet 'ruby', 'parallel_assignment_to_sequential_assignment'
  add_snippet 'ruby', 'use_symbol_to_proc'
end
