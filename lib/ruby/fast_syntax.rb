# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'fast_syntax' do
  description <<~EOS
    Use ruby fast syntax.

    Reference: https://speakerdeck.com/sferik/writing-fast-ruby
  EOS

  add_snippet 'ruby', 'block_to_yield'
  add_snippet 'ruby', 'gsub_to_tr'
  add_snippet 'ruby', 'keys_each_to_each_key'
  add_snippet 'ruby', 'map_and_flatten_to_flat_map'
  add_snippet 'ruby', 'merge_to_square_brackets'
  add_snippet 'ruby', 'parallel_assignment_to_sequential_assignment'
  add_snippet 'ruby', 'use_symbol_to_proc'
  add_snippet 'ruby', 'prefer_nil'
end
