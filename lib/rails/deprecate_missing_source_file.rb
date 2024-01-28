# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'deprecate_missing_source_file' do
  configure(parser: Synvert::PARSER_PARSER)

  description 'It replaces `MissingSourceFile` with `LoadError`.'

  if_gem 'rails', '>= 5.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # MissingSourceFile
    # =>
    # LoadError
    with_node node_type: 'const', to_source: 'MissingSourceFile' do
      replace_with 'LoadError'
    end
  end
end
