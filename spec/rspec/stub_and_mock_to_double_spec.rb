require 'spec_helper'

RSpec.describe 'RSpec converts stub and mock to double' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/stub_and_mock_to_double.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) { "
describe Post do
  it 'test' do
    stub('something')
    mock('something')
  end
end
    "}
    let(:post_spec_rewritten_content) { "
describe Post do
  it 'test' do
    double('something')
    double('something')
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
