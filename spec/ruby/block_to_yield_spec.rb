# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby converts block to yield' do
  let(:rewriter_name) { 'ruby/block_to_yield' }
  let(:test_content) {
    '
def test(&block)
  block.call
end

def test(foo, bar, &block)
  block.call foo, bar
end
  '
  }
  let(:test_rewritten_content) {
    '
def test
  yield
end

def test(foo, bar)
  yield(foo, bar)
end
  '
  }

  include_examples 'convertable'
end
