# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_2_3_to_2_4' do
  description <<~EOS
    It upgrades ruby 2.3 to 2.4
  EOS

  add_snippet 'ruby', 'deprecate_dir_exists'
  add_snippet 'ruby', 'deprecate_file_exists'
end
