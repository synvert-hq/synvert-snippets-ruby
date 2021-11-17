# frozen_string_literal: true

Synvert::Rewriter.new 'default', 'check_syntax' do
  description 'Just used to check if there is a syntax error.'

  within_files Synvert::ALL_RUBY_FILES do
  end
end
