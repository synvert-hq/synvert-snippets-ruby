# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_2_4_to_2_5' do
  description <<~EOS
    It upgrades ruby 2.4 to 2.5
  EOS

  add_snippet 'ruby', 'deprecate_dir_exists'
  add_snippet 'ruby', 'deprecate_file_exists'
end
