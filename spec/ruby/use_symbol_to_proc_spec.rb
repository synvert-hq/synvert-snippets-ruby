require 'spec_helper'

describe 'Ruby uses symbol to proc' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/use_symbol_to_proc.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) {"
(1..100).map { |i| i.to_s }
enum.map { |e| e[:object_id] }
(1..100).each { |i| i.to_s }
    "}
    let(:test_rewritten_content) {"
(1..100).map(&:to_s)
enum.map { |e| e[:object_id] }
(1..100).each(&:to_s)
    "}

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
