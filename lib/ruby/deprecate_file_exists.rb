# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'deprecate_file_exists' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    `File.exists?` is deprecated in Ruby 2.1.0, and removed in Ruby 3.2.0.

    Replace it with `File.exist?`.
  EOS

  if_ruby '2.1.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    find_node '.call_node[receiver=File][name=exists?][arguments=.arguments_node[arguments.size=1]]' do
      replace :name, with: 'exist?'
    end
  end
end
