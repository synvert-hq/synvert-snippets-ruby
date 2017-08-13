require 'spec_helper'

RSpec.describe 'RSpec converts negative error expectation' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/negative_error_expectation.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) { "
describe Post do
  it 'test' do
    expect { do_something }.not_to raise_error(SomeErrorClass)
    expect { do_something }.not_to raise_error('message')
    expect { do_something }.not_to raise_error(SomeErrorClass, 'message')
  end
end
    "}
    let(:post_spec_rewritten_content) { "
describe Post do
  it 'test' do
    expect { do_something }.not_to raise_error
    expect { do_something }.not_to raise_error
    expect { do_something }.not_to raise_error
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
