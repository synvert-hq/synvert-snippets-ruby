require 'spec_helper'

RSpec.describe 'Ruby uses symbol to proc' do
  let(:rewriter_name) { 'ruby/use_symbol_to_proc' }
  let(:test_content) {
    '
(1..100).map { |i| i.to_s }
enum.map { |e| e[:object_id] }
(1..100).each { |i| i.to_s }
  '
  }
  let(:test_rewritten_content) {
    '
(1..100).map(&:to_s)
enum.map { |e| e[:object_id] }
(1..100).each(&:to_s)
  '
  }

  include_examples 'convertable'
end
