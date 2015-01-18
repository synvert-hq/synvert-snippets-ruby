require 'spec_helper'

RSpec.describe 'RSpec converts boolean matcher' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/boolean_matcher.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) {"
describe Post do
  it 'case' do
    expect(obj).to be_true
    expect(obj).to be_false
  end
end
    "}
    let(:post_spec_rewritten_content) {"
describe Post do
  it 'case' do
    expect(obj).to be_truthy
    expect(obj).to be_falsey
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
