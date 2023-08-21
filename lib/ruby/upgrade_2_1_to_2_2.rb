# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_2_1_to_2_2' do
  description <<~EOS
    It upgrades ruby 2.1 to 2.2
  EOS

  add_snippet 'ruby', 'new_2_2_hash_syntax'
end
