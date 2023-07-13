# frozen_string_literal: true

Synvert::Rewriter.new 'default', 'check_syntax' do
  configure(parser: Synvert::PARSER_PARSER)

  description 'Just used to check if there is a syntax error.'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
  end
end
