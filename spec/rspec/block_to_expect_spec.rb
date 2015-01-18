require 'spec_helper'

RSpec.describe 'RSpec converts block to expect' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/block_to_expect.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) {"
describe Post do
  it 'test' do
    lambda { do_something }.should raise_error
    proc { do_something }.should raise_error
    -> { do_something }.should raise_error
  end
end
    "}
    let(:post_spec_rewritten_content) {"
describe Post do
  it 'test' do
    expect { do_something }.to raise_error
    expect { do_something }.to raise_error
    expect { do_something }.to raise_error
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
