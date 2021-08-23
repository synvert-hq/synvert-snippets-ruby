# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby removes debug_me calls' do
  let(:rewriter_name) { 'debug_me/remove_debug_me_calls' }
  let(:test_content) { <<~EOS }
    def test
      debug_me
      debug_me('== HERE ==')
      debug_me{}
      debug_me{[ :hello, 'world' ]}
      debug_me(tag: 'ERROR', levels: 5){[ :hello, :world ]}
      #
      DebugMe.debug_me
      DebugMe.debug_me('== HERE ==')
      DebugMe.debug_me{}
      DebugMe.debug_me{[ :hello, 'world' ]}
      DebugMe.debug_me(tag: 'ERROR', levels: 5){[ :hello, :world ]}
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    def test
      #
    end
  EOS

  include_examples 'convertable'
end
