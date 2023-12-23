# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_2_7_to_3_0' do
  description <<~EOS
    It upgrades ruby 2.7 to 3.0
  EOS

  add_snippet 'ruby', 'deprecate_dir_exists'
  add_snippet 'ruby', 'deprecate_file_exists'
  add_snippet 'ruby', 'uri_escape_to_uri_default_parser_escape'
end
