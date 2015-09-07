require 'spec_helper'

RSpec.describe 'Ruby removes debug code' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/remove_debug_code.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) {"
def test
  puts 'hello world'
  p 'debug'
end
    "}
    let(:test_rewritten_content) {"
def test
end
    "}

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
