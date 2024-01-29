# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_2_5_to_2_6' do
  description 'It upgrades ruby 2.5 to 2.6.'

  add_snippet 'ruby', 'deprecate_big_decimal_new'
  add_snippet 'ruby', 'deprecate_dir_exists'
  add_snippet 'ruby', 'deprecate_file_exists'
  add_snippet 'ruby', 'deprecate_fixnum_and_bignum'
end
