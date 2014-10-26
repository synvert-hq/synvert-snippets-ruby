require 'spec_helper'

RSpec.describe 'Ruby converts map_and_flatten_to_flat_map' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/map_and_flatten_to_flat_map.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) {"
enum.map do
  # do something
end.flatten
    "}
    let(:test_rewritten_content) {"
enum.flat_map do
  # do something
end
    "}

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
