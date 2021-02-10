# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby uses new hash synax in ruby 2.2' do
  let(:rewriter_name) { 'ruby/new_hash_syntax_ruby22' }
  let(:test_content) {
    <<~'EOF'
      {:foo => 'bar', 'foo' => 'bar'}
      {:key1 => 'value1', :key2 => 'value2'}
      {foo_key: 'foo_value', bar_key: 42, "baz-key" => true}
      {:"foo-#{key}" => 'foo_value', :"bar-key" => 42, :"a\tb" => false, :"c'd" => nil}
      {"foo-#{key}": 'foo_value', 'bar-key': 42, "a\tb": false, "c'd": nil}
    EOF
  }
  let(:test_rewritten_content) {
    <<~'EOF'
      {foo: 'bar', 'foo' => 'bar'}
      {key1: 'value1', key2: 'value2'}
      {foo_key: 'foo_value', bar_key: 42, "baz-key" => true}
      {"foo-#{key}": 'foo_value', 'bar-key': 42, "a\tb": false, "c'd": nil}
      {"foo-#{key}": 'foo_value', 'bar-key': 42, "a\tb": false, "c'd": nil}
    EOF
  }

  include_examples 'convertable'
end
