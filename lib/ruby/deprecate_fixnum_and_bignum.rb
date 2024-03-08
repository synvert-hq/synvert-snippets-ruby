# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'deprecate_fixnum_and_bignum' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    Unify Fixnum and Bignum into Integer.
  EOS

  if_ruby '2.4.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    find_node '.constant_read_node[name IN (Fixnum Bignum)]' do
      replace_with 'Integer'
    end
  end
end
