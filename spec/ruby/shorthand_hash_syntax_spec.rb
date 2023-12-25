# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Uses ruby 3.1 shorthand hash synax' do
  let(:rewriter_name) { 'ruby/shorthand_hash_syntax' }

  let(:test_content) { <<~EOS }
    { a: a, b: b, c: c, d: d + 4 }
    some_method(a: a, b: b, c: c, d: d + 4)
    some_method(:a => a, :b => b, :c => c, :d => d + 4)
    some_method a: a, b: b, c: c, d: d + 4
  EOS

  let(:test_rewritten_content) { <<~EOS }
    { a:, b:, c:, d: d + 4 }
    some_method(a:, b:, c:, d: d + 4)
    some_method(:a => a, :b => b, :c => c, :d => d + 4)
    some_method a: a, b: b, c: c, d: d + 4
  EOS

  include_examples 'convertable'
end
