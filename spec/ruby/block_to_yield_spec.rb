require 'spec_helper'

describe 'Ruby converts block to yield' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/block_to_yield.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) {"
def test(&block)
  block.call
end

def test(foo, bar, &block)
  block.call foo, bar
end
    "}
    let(:test_rewritten_content) {"
def test
  yield
end

def test(foo, bar)
  yield foo, bar
end
    "}

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
