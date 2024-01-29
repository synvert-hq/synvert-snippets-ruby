# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_3_3_to_3_4' do
  description 'It upgrades ruby 3.3 to 3.4.'

  add_snippet 'ruby', 'use_it_keyword'
end
