# frozen_string_literal: true

Synvert::Rewriter.new 'debug_me', 'remove_debug_me_calls' do
  description <<~EOS
    It removes `debug_me` calls.

    debug_me  A tool to print the labeled value of variables.
              |__ http://github.com/MadBomber/debug_me
  EOS

  within_files '**/*.rb' do
    # removes debug_me methods
    # removes all debug_me calls that have a block
    with_node type: 'block', caller: { type: 'send', message: 'debug_me'} do
      remove
    end

    # removes all debug_me calls that DO NOT have a block
    with_node type: 'send', message: 'debug_me' do
      remove
    end
  end
end
