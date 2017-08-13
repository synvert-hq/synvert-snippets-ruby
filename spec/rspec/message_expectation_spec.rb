require 'spec_helper'

RSpec.describe 'RSpec converts message expectation' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/message_expectation.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) { "
describe Post do
  it 'test' do
    obj.should_receive(:message)
    Klass.any_instance.should_receive(:message)
    obj.should_not_receive(:message)
    Klass.any_instance.should_not_receive(:message)

    expect(obj).to receive(:message).and_return { 1 }

    expect(obj).to receive(:message).and_return
  end
end
    "}
    let(:post_spec_rewritten_content) { "
describe Post do
  it 'test' do
    expect(obj).to receive(:message)
    expect_any_instance_of(Klass).to receive(:message)
    expect(obj).not_to receive(:message)
    expect_any_instance_of(Klass).not_to receive(:message)

    expect(obj).to receive(:message) { 1 }

    expect(obj).to receive(:message)
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
