# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_2_1_to_2_2' do
  description 'It upgrades ruby 2.1 to 2.2.'

  add_snippet 'ruby', 'deprecate_dir_exists'
  add_snippet 'ruby', 'deprecate_file_exists'
  add_snippet 'ruby', 'new_2_2_hash_syntax'
end
