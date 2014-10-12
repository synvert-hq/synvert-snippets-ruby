require 'spec_helper'

describe 'Ruby fetch uses block default' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/fetch_use_block_default.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) {"
{:rails => :club}.fetch(:rails, (0..9).to_a)
    "}
    let(:test_rewritten_content) {"
{:rails => :club}.fetch(:rails) { (0..9).to_a }
    "}

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
