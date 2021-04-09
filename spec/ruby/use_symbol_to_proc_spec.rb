# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby uses symbol to proc' do
  let(:rewriter_name) { 'ruby/use_symbol_to_proc' }
  let(:test_content) { <<~EOS }
    (1..100).map { |i| i.to_s }
    enum.map { |e| e[:object_id] }
    (1..100).each { |i| i.to_s }
  EOS

  let(:test_rewritten_content) { <<~EOS }
    (1..100).map(&:to_s)
    enum.map { |e| e[:object_id] }
    (1..100).each(&:to_s)
  EOS

  include_examples 'convertable'
end
