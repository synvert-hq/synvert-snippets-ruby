require 'spec_helper'

RSpec.describe 'Ruby uses new hash synax' do
  let(:rewriter_name) { 'ruby/new_hash_syntax' }

  let(:test_content) {
    "
{:foo => 'bar', 'foo' => 'bar'}
{:key1 => 'value1', :key2 => 'value2'}
{foo_key: 'foo_value', bar_key: 42}
{:'foo-key' => 'foo_value', :'bar-key' => 42}
  "
  }
  let(:test_rewritten_content) {
    "
{foo: 'bar', 'foo' => 'bar'}
{key1: 'value1', key2: 'value2'}
{foo_key: 'foo_value', bar_key: 42}
{:'foo-key' => 'foo_value', :'bar-key' => 42}
  "
  }

  include_examples 'convertable'
end
