require 'spec_helper'

RSpec.describe 'RSpec converts be_close to be_within' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/be_close_to_be_within.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) {"
describe Post do
  it 'test' do
    expect(1.0 / 3.0).to be_close(0.333, 0.001)
  end
end
    "}
    let(:post_spec_rewritten_content) {"
describe Post do
  it 'test' do
    expect(1.0 / 3.0).to be_within(0.001).of(0.333)
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
