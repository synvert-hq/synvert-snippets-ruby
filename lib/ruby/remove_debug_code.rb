# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'remove_debug_code' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It removes `puts` and `p` calls.
  EOS

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # removes puts and p methods
    find_node '.call_node[receiver=nil][name IN (puts p)]' do
      remove
    end
  end
end
