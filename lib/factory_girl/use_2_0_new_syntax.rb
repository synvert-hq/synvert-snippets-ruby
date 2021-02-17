# frozen_string_literal: true

Synvert::Rewriter.new 'factory_girl', 'use_new_syntax' do
  description 'It uses factory_girl new syntax.'

  add_snippet 'factory_girl', 'use_short_syntax'
  add_snippet 'factory_girl', 'fix_2_0_deprecations'
end
