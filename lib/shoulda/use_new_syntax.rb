# frozen_string_literal: true

Synvert::Rewriter.new 'shoulda', 'use_new_syntax' do
  description 'It calls shoulda/use_matcher_syntax and shoulda/fix_deprecations snippets.'

  add_snippet 'shoulda', 'use_short_syntax'
  add_snippet 'shoulda', 'fix_deprecations'
end
