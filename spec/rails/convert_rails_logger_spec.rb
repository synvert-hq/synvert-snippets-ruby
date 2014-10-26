require 'spec_helper'

RSpec.describe 'Upgrade RAILS_DEFAULT_LOGGER to Rails.logger' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/convert_rails_logger.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:constant_content) {"
RAILS_DEFAULT_LOGGER
::RAILS_DEFAULT_LOGGER
    "}
    let(:constant_rewritten_content) {"
Rails.logger
Rails.logger
    "}

    it 'converts' do
      FileUtils.mkdir_p 'config/initializers'
      File.write 'config/initializers/constant.rb', constant_content
      @rewriter.process
      expect(File.read 'config/initializers/constant.rb').to eq constant_rewritten_content
    end
  end
end
