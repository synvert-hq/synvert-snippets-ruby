# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_3_0_to_3_1' do
  description <<~EOS
    It upgrades ruby 3.0 to 3.1
  EOS

  add_snippet 'ruby', 'hash_short_syntax'
end
