# frozen_string_literal: true

Synvert::Rewriter.new 'factory_girl', 'use_2_0_new_syntax' do
  description 'It uses factory_girl 2.0 new syntax.'

  add_snippet 'factory_girl', 'use_short_syntax'
  add_snippet 'factory_girl', 'fix_deprecations'
end
