# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_2_5_to_2_6' do
  description <<~EOS
    It upgrades ruby 2.5 to 2.6
  EOS

  add_snippet 'ruby', 'deprecate_big_decimal_new'
end
