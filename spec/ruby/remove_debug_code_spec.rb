# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby removes debug code' do
  let(:rewriter_name) { 'ruby/remove_debug_code' }
  let(:test_content) { <<~EOS }
    def test
      puts 'hello world'
      p 'debug'
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    def test
    end
  EOS

  include_examples 'convertable'
end
