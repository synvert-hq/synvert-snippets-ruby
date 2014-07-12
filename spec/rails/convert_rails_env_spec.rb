require 'spec_helper'

describe 'Convert RAILS_ENV to Rails.env' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/convert_rails_env.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:constant_content) {"""
RAILS_ENV
RAILS_ENV == 'test'
'development' == RAILS_ENV
RAILS_ENV != 'test'
'development' != RAILS_ENV
    """}
    let(:constant_rewritten_content) {"""
Rails.env
Rails.env.test?
Rails.env.development?
!Rails.env.test?
!Rails.env.development?
    """}

    it 'converts' do
      FileUtils.mkdir_p 'config/initializers'
      File.write 'config/initializers/constant.rb', constant_content
      @rewriter.process
      expect(File.read 'config/initializers/constant.rb').to eq constant_rewritten_content
    end
  end
end
