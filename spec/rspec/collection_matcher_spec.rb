require 'spec_helper'

RSpec.describe 'RSpec converts collection matcher' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/collection_matcher.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) {"
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
    let(:post_spec_rewritten_content) {"
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

    it 'converts' do
      FileUtils.mkdir_p 'spec/models'
      File.write 'spec/models/post_spec.rb', post_spec_content
      rewriter.process
      expect(File.read 'spec/models/post_spec.rb').to eq post_spec_rewritten_content
    end
  end
end
