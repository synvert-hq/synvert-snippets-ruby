# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_constants_5_0_to_5_1' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts rails constants from 5.0 to 5.1.

    It replaces `HashWithIndifferentAccess` with `ActiveSupport::HashWithIndifferentAccess`.
  EOS

  if_gem 'rails', '>= 5.1'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # HashWithIndifferentAccess
    # =>
    # ActiveSupport::HashWithIndifferentAccess
    with_node node_type: 'const', to_source: 'HashWithIndifferentAccess' do
      replace_with 'ActiveSupport::HashWithIndifferentAccess'
    end
  end
end
