# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_2_6_to_2_7' do
  description <<~EOS
    It upgrades ruby 2.6 to 2.7
  EOS

  add_snippet 'ruby', 'deprecate_big_decimal_new'
  add_snippet 'ruby', 'deprecate_dir_exists'
  add_snippet 'ruby', 'deprecate_file_exists'
  add_snippet 'ruby', 'deprecate_fixnum_and_bignum'
  add_snippet 'ruby', 'kernel_open_to_uri_open'
  add_snippet 'ruby', 'numbered_parameters'
  add_snippet 'ruby', 'uri_escape_to_uri_default_parser_escape'
end
