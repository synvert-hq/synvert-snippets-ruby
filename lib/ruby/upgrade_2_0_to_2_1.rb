# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_2_0_to_2_1' do
  description 'It upgrades ruby 2.0 to 2.1.'

  add_snippet 'ruby', 'deprecate_dir_exists'
  add_snippet 'ruby', 'deprecate_file_exists'
end
