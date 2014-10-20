require 'spec_helper'

describe 'Ruby .keys.each to .each_key' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/keys_each_to_each_key.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) {"
params.keys.each do |param|
end
    "}
    let(:test_rewritten_content) {"
params.each_key do |param|
end
    "}

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
