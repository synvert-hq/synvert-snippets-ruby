# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_2_3_to_2_4' do
  description 'It upgrades ruby 2.3 to 2.4.'

  add_snippet 'ruby', 'deprecate_dir_exists'
  add_snippet 'ruby', 'deprecate_file_exists'
  add_snippet 'ruby', 'deprecate_fixnum_and_bignum'
end
