require 'spec_helper'

RSpec.describe 'Ruby converts Kernel#open to URI.open' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/kernel_open_to_uri_open.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) { "open('http://test.com')" }
    let(:test_rewritten_content) { "URI.open('http://test.com')" }

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
