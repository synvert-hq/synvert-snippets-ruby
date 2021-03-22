# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Uses ruby 2.2 new hash synax' do
  let(:rewriter_name) { 'ruby/new_2_2_hash_syntax' }
  let(:test_content) { <<~'EOS' }
    { :foo => 'bar', 'foo' => 'bar' }
    { :key1 => 'value1', :key2 => 'value2' }
    { foo_key: 'foo_value', bar_key: 42, "baz-key" => true }
    { :"foo-#{key}" => 'foo_value', :"bar-key" => 42, :"a\tb" => false, :"c'd" => nil }
    { "foo-#{key}": 'foo_value', 'bar-key': 42, "a\tb": false, "c'd": nil }
  EOS

  let(:test_rewritten_content) { <<~'EOS' }
    { foo: 'bar', 'foo' => 'bar' }
    { key1: 'value1', key2: 'value2' }
    { foo_key: 'foo_value', bar_key: 42, "baz-key" => true }
    { "foo-#{key}": 'foo_value', 'bar-key': 42, "a\tb": false, "c'd": nil }
    { "foo-#{key}": 'foo_value', 'bar-key': 42, "a\tb": false, "c'd": nil }
  EOS

  before do
    load_sub_snippets(%w[ruby/new_1_9_hash_syntax])
  end

  include_examples 'convertable'
end
