# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_constants_4_2_to_5_0' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts rails constants from 4.2 to 5.0.

    It replaces `MissingSourceFile` with `LoadError`.
  EOS

  if_gem 'rails', '>= 5.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # MissingSourceFile
    # =>
    # LoadError
    with_node node_type: 'constant_read_node', name: 'MissingSourceFile' do
      replace_with 'LoadError'
    end
  end
end
