# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_3_1_to_3_2' do
  description <<~EOS
    It upgrades ruby 3.1 to 3.2
  EOS

  add_snippet 'ruby', 'deprecate_dir_exists'
  add_snippet 'ruby', 'deprecate_file_exists'
end
