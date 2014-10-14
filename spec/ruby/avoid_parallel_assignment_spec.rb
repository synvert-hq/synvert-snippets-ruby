require 'spec_helper'

describe 'Ruby avoids parallel_assignment' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/avoid_parallel_assignment.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) {"
a, b = 1, 2

a, b = params
    "}
    let(:test_rewritten_content) {"
a = 1
b = 2

a, b = params
    "}

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
