# frozen_string_literal: true

Synvert::Rewriter.new 'default', 'check_syntax' do
  description 'just used to check if there are syntax errors.'

  within_files '**/*.rb' do; end
end
