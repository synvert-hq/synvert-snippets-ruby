# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby uses keyword arguments' do
  let(:rewriter_name) { 'ruby/use_keyword_arguments' }
  let(:test_content) { <<~EOS }
    CSV.generate(options) do |csv|
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    CSV.generate(**options) do |csv|
    end
  EOS

  include_examples 'convertable'
end
