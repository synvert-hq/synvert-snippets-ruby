# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_3_3_to_3_4' do
  description <<~EOS
    It upgrades ruby 3.3 to 3.4
  EOS

  add_snippet 'ruby', 'use_it_keyword'
end
