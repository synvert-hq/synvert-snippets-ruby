require 'spec_helper'

RSpec.describe 'RSpec converts its to it' do
  let(:rewriter_name) { 'rspec/its_to_it' }
  let(:fake_file_path) { 'spec/models/post_spec.rb' }
  let(:test_content) {
    "
describe Post do
  describe 'example' do
    subject { { foo: 1, bar: 2 } }
    its(:size) { should == 2 }
    its([:foo]) { should == 1 }
    its('keys.first') { should == :foo }
  end
end
  "
  }
  let(:test_rewritten_content) {
    "
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
  "
  }

  include_examples 'convertable'
end
