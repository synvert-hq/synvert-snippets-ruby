# frozen_string_literal: true

Synvert::Rewriter.new 'shoulda', 'use_new_syntax' do
  description 'It uses shoulda new syntax and fix deprecations.'

  add_snippet 'shoulda', 'use_matcher_syntax'
  add_snippet 'shoulda', 'fix_1_5_deprecations'
  add_snippet 'shoulda', 'fix_2_6_deprecations'
end
