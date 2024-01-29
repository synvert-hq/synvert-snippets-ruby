# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_3_0_to_3_1' do
  description 'It upgrades ruby 3.0 to 3.1.'

  add_snippet 'ruby', 'deprecate_dir_exists'
  add_snippet 'ruby', 'deprecate_file_exists'
  add_snippet 'ruby', 'deprecate_fixnum_and_bignum'
  add_snippet 'ruby', 'shorthand_hash_syntax'
end
