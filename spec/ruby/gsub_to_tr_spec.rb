require 'spec_helper'

RSpec.describe 'Ruby converts gsub to tr' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/gsub_to_tr.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) {"
'slug from title'.gsub(' ', '_')
    "}
    let(:test_rewritten_content) {"
'slug from title'.tr(' ', '_')
    "}

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
