# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Ruby converts map_and_flatten_to_flat_map' do
  let(:rewriter_name) { 'ruby/map_and_flatten_to_flat_map' }
  let(:test_content) { "
enum.map do
  # do something
end.flatten
  "}
  let(:test_rewritten_content) { "
enum.flat_map do
  # do something
end
  "}

  include_examples 'convertable'
end
