# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby .keys.each to .each_key' do
  let(:rewriter_name) { 'ruby/keys_each_to_each_key' }
  let(:test_content) { <<~EOS }
    params.keys.each do |param|
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    params.each_key do |param|
    end
  EOS

  include_examples 'convertable'
end
