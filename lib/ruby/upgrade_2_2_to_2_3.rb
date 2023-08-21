# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_2_2_to_2_3' do
  description <<~EOS
    It upgrades ruby 2.2 to 2.3
  EOS

  add_snippet 'ruby', 'new_safe_navigation_operator'
end
