require 'spec_helper'

RSpec.describe 'RSpec converts method stub' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/method_stub.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) { "
describe Post do
  it 'case' do
    obj.stub(:message)
    obj.stub!(:message)
    obj.stub_chain(:foo, :bar, :baz)
    Klass.any_instance.stub(:message)

    obj.stub(:foo => 1, :bar => 2)

    obj.unstub!(:message)

    obj.stub(:message).any_number_of_times
    obj.stub(:message).at_least(0)

    allow(obj).to receive(:message).and_return { 1 }

    allow(obj).to receive(:message).and_return
  end
end
    "}
    let(:post_spec_rewritten_content) { "
describe Post do
  it 'case' do
    allow(obj).to receive(:message)
    allow(obj).to receive(:message)
    allow(obj).to receive_message_chain(:foo, :bar, :baz)
    allow_any_instance_of(Klass).to receive(:message)

    allow(obj).to receive_messages(:foo => 1, :bar => 2)

    obj.unstub(:message)

    allow(obj).to receive(:message)
    allow(obj).to receive(:message)

    allow(obj).to receive(:message) { 1 }

    allow(obj).to receive(:message)
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
