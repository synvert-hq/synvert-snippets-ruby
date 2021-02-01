# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'RSpec converts collection matcher' do
  let(:rewriter_name) { 'rspec/collection_matcher' }
  let(:fake_file_path) { 'spec/models/post_spec.rb' }
  let(:test_content) { "
describe Post do
  it 'test' do
    expect(collection).to have(3).items
    expect(collection).to have_exactly(3).items
    expect(collection).to have_at_least(3).items
    expect(collection).to have_at_most(3).items

    expect(team).to have(3).players
  end
end
  "}
  let(:test_rewritten_content) { "
describe Post do
  it 'test' do
    expect(collection.size).to eq 3
    expect(collection.size).to eq 3
    expect(collection.size).to be >= 3
    expect(collection.size).to be <= 3

    expect(team.players.size).to eq 3
  end
end
  "}

  include_examples 'convertable'
end
