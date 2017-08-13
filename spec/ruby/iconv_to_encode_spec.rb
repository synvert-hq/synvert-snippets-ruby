require 'spec_helper'

RSpec.describe 'Ruby Iconv#iconv to String#encode' do

  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/iconv_to_encode.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    describe 'basic case' do    
      let(:test_content) { "
        Iconv.new('Windows-1252','utf-8').iconv('some string')
      "}
      let(:test_rewritten_content) { "
        'some string'.force_encoding('utf-8').encode('Windows-1252')
      "}

      it 'converts' do
        File.write 'test.rb', test_content
        @rewriter.process
        expect(File.read 'test.rb').to eq test_rewritten_content
      end
    end
    
    describe 'with iconv ignored option' do
      let(:test_content) { "
        Iconv.new('Windows-1252//IGNORE','utf-8//IGNORE').iconv('some string')
      "}
      let(:test_rewritten_content) { "
        'some string'.force_encoding('utf-8').encode('Windows-1252', invalid: :replace, undef: :replace)
      "}

      it 'converts' do
        File.write 'test.rb', test_content
        @rewriter.process
        expect(File.read 'test.rb').to eq test_rewritten_content
      end
    end

    describe 'case with encodings set in vars' do
      let(:test_content) { "Iconv.new(to_charset, from_charset).iconv(line)" }
      let(:test_rewritten_content) { "line.force_encoding(from_charset).encode(to_charset)" }

      it 'converts' do
        File.write 'test.rb', test_content
        @rewriter.process
        expect(File.read 'test.rb').to eq test_rewritten_content
      end
    end

    describe 'remove iconv requires' do
      let(:test_content) { "
        require 'iconv'
        require 'foo'
      " }
      let(:test_rewritten_content) { "
        require 'foo'
      " }

      it 'converts' do
        File.write 'test.rb', test_content
        @rewriter.process 
        expect(File.read 'test.rb').to eq test_rewritten_content
      end
    end

  end
end
