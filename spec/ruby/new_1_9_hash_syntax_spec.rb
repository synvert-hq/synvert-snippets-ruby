# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Uses ruby 1.9 new hash synax' do
  let(:rewriter_name) { 'ruby/new_1_9_hash_syntax' }

  let(:test_content) { <<~EOS }
    { :foo => 'bar', 'foo' => 'bar' }
    { :key1 => 'value1', :key2 => 'value2' }
    { foo_key: 'foo_value', bar_key: 42 }
    { :'foo-key' => 'foo_value', :'bar-key' => 42 }
  EOS

  let(:test_rewritten_content) { <<~EOS }
    { foo: 'bar', 'foo' => 'bar' }
    { key1: 'value1', key2: 'value2' }
    { foo_key: 'foo_value', bar_key: 42 }
    { :'foo-key' => 'foo_value', :'bar-key' => 42 }
  EOS

  include_examples 'convertable'
end
