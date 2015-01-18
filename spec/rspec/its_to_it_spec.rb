require 'spec_helper'

RSpec.describe 'RSpec converts its to it' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/its_to_it.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) {"
describe Post do
  describe 'example' do
    subject { { foo: 1, bar: 2 } }
    its(:size) { should == 2 }
    its([:foo]) { should == 1 }
    its('keys.first') { should == :foo }
  end
end
    "}
    let(:post_spec_rewritten_content) {"
describe Post do
  describe 'example' do
    subject { { foo: 1, bar: 2 } }
    describe '#size' do
      subject { super().size }
      it { should == 2 }
    end
    describe '[:foo]' do
      subject { super()[:foo] }
      it { should == 1 }
    end
    describe '#keys' do
      subject { super().keys }
      describe '#first' do
        subject { super().first }
        it { should == :foo }
      end
    end
  end
end
    "}

    it 'converts' do
      FileUtils.mkdir_p 'spec/models'
      File.write 'spec/models/post_spec.rb', post_spec_content
      rewriter.process
      expect(File.read 'spec/models/post_spec.rb').to eq post_spec_rewritten_content
    end
  end
end
