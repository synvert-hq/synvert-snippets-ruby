# frozen_string_literal: true

Synvert::Rewriter.new 'debug_me', 'remove_debug_me_calls' do
  description <<~EOS
    It removes `debug_me` calls.

    debug_me  A tool to print the labeled value of variables.
              |__ http://github.com/MadBomber/debug_me
  EOS

  within_files Synvert::ALL_RUBY_FILES do
    # removes debug_me methods
    # removes all debug_me calls that have a block
    find_node '.block[caller=.send[message=debug_me]]' do
      remove
    end
  end

  within_files Synvert::ALL_RUBY_FILES do
    # removes all debug_me calls that DO NOT have a block
    find_node '.send[message=debug_me]' do
      remove
    end
  end
end
