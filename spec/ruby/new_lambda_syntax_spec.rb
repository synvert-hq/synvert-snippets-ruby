require 'spec_helper'

describe 'Ruby uses new -> synax' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/new_lambda_syntax.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) {"""
lambda { test }
lambda { |a, b, c| a + b + c }
    """}
    let(:test_rewritten_content) {"""
-> { test }
->(a, b, c) { a + b + c }
    """}

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
