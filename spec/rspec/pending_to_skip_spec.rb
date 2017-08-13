require 'spec_helper'

RSpec.describe 'RSpec converts pending to skip' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/pending_to_skip.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_spec_content) { "
describe 'example' do
  it 'is skipped', :pending => true do
    do_something_possibly_fail
  end

  pending 'is skipped' do
    do_something_possibly_fail
  end

  it 'is skipped' do
    pending
    do_something_possibly_fail
  end

  it 'is run and expected to fail' do
    pending do
      do_something_surely_fail
    end
  end
end
    "}

    let(:post_spec_rewritten_content) { "
describe 'example' do
  it 'is skipped', :skip => true do
    do_something_possibly_fail
  end

  skip 'is skipped' do
    do_something_possibly_fail
  end

  it 'is skipped' do
    skip
    do_something_possibly_fail
  end

  it 'is run and expected to fail' do
    skip
    do_something_surely_fail
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
