# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'upgrade_1_8_to_1_9' do
  description 'It upgrades ruby 1.8 to 1.9.'

  add_snippet 'ruby', 'new_1_9_hash_syntax'
  add_snippet 'ruby', 'new_lambda_syntax'
end
