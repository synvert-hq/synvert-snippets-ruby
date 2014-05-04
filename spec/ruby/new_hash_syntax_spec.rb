require 'spec_helper'

describe 'Ruby uses new hash synax' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/new_hash_syntax.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) {"""
{:foo => 'bar', 'foo' => 'bar'}
{:key1 => 'value1', :key2 => 'value2'}
{foo_key: 'foo_value', bar_key: 42}
    """}
    let(:test_rewritten_content) {"""
{foo: 'bar', 'foo' => 'bar'}
{key1: 'value1', key2: 'value2'}
{foo_key: 'foo_value', bar_key: 42}
    """}

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
