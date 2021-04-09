# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby converts parallel assignment to sequential assignment' do
  let(:rewriter_name) { 'ruby/parallel_assignment_to_sequential_assignment' }
  let(:test_content) { <<~EOS }
    a, b = 1, 2
    a, b = params
  EOS

  let(:test_rewritten_content) { <<~EOS }
    a = 1
    b = 2
    a, b = params
  EOS

  include_examples 'convertable'
end
