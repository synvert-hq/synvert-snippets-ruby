require 'spec_helper'

RSpec.describe 'RSpec converts one liner expectation' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/one_liner_expectation.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) {"
describe Post do
  it { should matcher }
  it { should_not matcher }

  it { should have(3).items }
  it { should have_at_least(3).players }
end
    "}
    let(:post_spec_rewritten_content) {"
describe Post do
  it { is_expected.to matcher }
  it { is_expected.not_to matcher }

  it 'has 3 items' do
    expect(subject.size).to eq(3)
  end
  it 'has at least 3 players' do
    expect(subject.players.size).to be >= 3
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
