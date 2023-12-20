# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'deprecate_dir_exists' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    `Dir.exists?` is deprecated in Ruby 2.1.0, and removed in Ruby 3.2.0.

    Replace it with `Dir.exist?`.
  EOS

  if_ruby '2.1.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    find_node '.send[receiver=Dir][message=exists?]' do
      replace :message, with: 'exist?'
    end
  end
end
