# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_2_2_to_2_3' do
  description 'It upgrades ruby 2.2 to 2.3.'

  add_snippet 'ruby', 'deprecate_dir_exists'
  add_snippet 'ruby', 'deprecate_file_exists'
  add_snippet 'ruby', 'new_safe_navigation_operator'
end
