# frozen_string_literal: true
Synvert::Rewriter.new 'factory_girl', 'use_new_syntax' do
  description 'It calls factory_girl/use_short_syntax and factory_girl/fix_deprecations snippets.'

  add_snippet 'factory_girl', 'use_short_syntax'
  add_snippet 'factory_girl', 'fix_deprecations'
end
