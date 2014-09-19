require 'spec_helper'

describe 'Convert RAILS_ROOT to Rails.root' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/convert_rails_root.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:constant_content) {'
RAILS_ROOT
::RAILS_ROOT
File.join(RAILS_ROOT, "config", "database.yml")
RAILS_ROOT + "/config/database.yml"
"#{RAILS_ROOT}/config/database.yml"
    '}
    let(:constant_rewritten_content) {'
Rails.root
Rails.root
Rails.root.join("config", "database.yml")
Rails.root.join("config/database.yml")
Rails.root.join("config/database.yml")
    '}

    it 'converts' do
      FileUtils.mkdir_p 'config/initializers'
      File.write 'config/initializers/constant.rb', constant_content
      @rewriter.process
      expect(File.read 'config/initializers/constant.rb').to eq constant_rewritten_content
    end
  end
end
