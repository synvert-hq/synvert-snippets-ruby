require 'spec_helper'

RSpec.describe 'Hash value shorthand' do
  let(:rewriter_name) { 'ruby/hash_value_shorthand' }
  let(:fake_file_path) { 'foobar.rb' }

  context 'hash' do
    let(:test_content) { 'hash = { x: x, y: y }' }
    let(:test_rewritten_content) { 'hash = { x:, y: }' }

    include_examples 'convertable'
  end

  context 'keyword arguments' do
    let(:test_content) { 'foobar(x: x, y: y)' }
    let(:test_rewritten_content) { 'foobar(x:, y:)' }

    include_examples 'convertable'
  end
end