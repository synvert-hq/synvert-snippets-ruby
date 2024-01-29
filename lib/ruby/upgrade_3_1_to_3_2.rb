# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_3_1_to_3_2' do
  description 'It upgrades ruby 3.1 to 3.2.'

  add_snippet 'ruby', 'deprecate_dir_exists'
  add_snippet 'ruby', 'deprecate_file_exists'
  add_snippet 'ruby', 'deprecate_fixnum_and_bignum'
end
