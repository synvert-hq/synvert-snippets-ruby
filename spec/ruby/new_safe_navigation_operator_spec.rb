require 'spec_helper'

RSpec.describe 'Ruby uses new safe navigation operator', skip: Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.3.0') do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/ruby/new_safe_navigation_operator.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:test_content) {"
u = User.find(id)
u.try!(:profile).try!(:thumbnails).try!(:large, 100, format: 'jpg')
u.try!('profile').try!('thumbnails').try!('large', 100, format: 'jpg')
u.try(:profile).try(:thumbnails).try(:large, 100, format: 'jpg')
u.try('profile').try('thumbnails').try('large', 100, format: 'jpg')
    "}
    let(:test_rewritten_content) {"
u = User.find(id)
u&.profile&.thumbnails&.large(100, format: 'jpg')
u&.profile&.thumbnails&.large(100, format: 'jpg')
u&.profile&.thumbnails&.large(100, format: 'jpg')
u&.profile&.thumbnails&.large(100, format: 'jpg')
    "}

    it 'converts' do
      File.write 'test.rb', test_content
      @rewriter.process
      expect(File.read 'test.rb').to eq test_rewritten_content
    end
  end
end
