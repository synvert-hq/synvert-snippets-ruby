require 'spec_helper'

RSpec.describe 'RSpec uses new hook scope' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/new_hook_scope.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) { "
describe 'example' do
  before { do_something }
  before(:each) { do_something }
  before(:all) { do_something }
end
    "}
    let(:post_spec_rewritten_content) { "
describe 'example' do
  before { do_something }
  before(:example) { do_something }
  before(:context) { do_something }
end
    "}
    let(:spec_helper_content) { "
RSpec.configure do |config|
  config.before(:suite) { do_something }
end
    "}
    let(:spec_helper_rewritten_content) { "
RSpec.configure do |config|
  config.before(:suite) { do_something }
end
    "}

    it 'converts' do
      FileUtils.mkdir_p 'spec/models'
      File.write 'spec/models/post_spec.rb', post_spec_content
      File.write 'spec/spec_helper.rb', spec_helper_content
      rewriter.process
      expect(File.read 'spec/models/post_spec.rb').to eq post_spec_rewritten_content
      expect(File.read 'spec/spec_helper.rb').to eq spec_helper_rewritten_content
    end
  end
end
