# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Uses ruby 3.1 hash short synax' do
  let(:rewriter_name) { 'ruby/hash_short_syntax' }

  let(:test_content) { <<~EOS }
    some_method(a: a, b: b, c: c, d: d + 4)
  EOS

  let(:test_rewritten_content) { <<~EOS }
    some_method(a:, b:, c:, d: d + 4)
  EOS

  include_examples 'convertable'
end
