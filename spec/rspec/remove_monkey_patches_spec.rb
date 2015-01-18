require 'spec_helper'

RSpec.describe 'RSpec removes monkey patches' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/remove_monkey_patches.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) {"
describe Post do
  describe '.active' do
  end
end
    "}
    let(:post_spec_rewritten_content) {"
RSpec.describe Post do
  describe '.active' do
  end
end
    "}
    let(:post_support_content) {"
shared_examples 'shared examples' do
end
    "}
    let(:post_support_rewritten_content) {"
RSpec.shared_examples 'shared examples' do
end
    "}
    let(:spec_helper_content) {"
RSpec.configure do |config|
end
    "}
    let(:spec_helper_rewritten_content) {"
RSpec.configure do |config|
  config.expose_dsl_globally = false
end
    "}

    it 'converts' do
      FileUtils.mkdir_p 'spec/models'
      FileUtils.mkdir_p 'spec/supports'
      File.write 'spec/models/post_spec.rb', post_spec_content
      File.write 'spec/supports/post.rb', post_support_content
      File.write 'spec/spec_helper.rb', spec_helper_content
      rewriter.process
      expect(File.read 'spec/models/post_spec.rb').to eq post_spec_rewritten_content
      expect(File.read 'spec/supports/post.rb').to eq post_support_rewritten_content
      expect(File.read 'spec/spec_helper.rb').to eq spec_helper_rewritten_content
    end
  end
end
