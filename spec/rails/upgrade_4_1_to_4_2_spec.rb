# encoding: utf-8

require 'spec_helper'

RSpec.describe 'Upgrade rails from 4.1 to 4.2' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/upgrade_4_1_to_4_2.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:application_content) {'
Synvert::Application.configure do
end
    '}
    let(:application_rewritten_content) {'
Synvert::Application.configure do
 config.active_record.raise_in_transactional_callbacks = true
end
    '}
    let(:production_content) {'
Synvert::Application.configure do
  config.serve_static_assets = false
end
    '}
    let(:production_rewritten_content) {'
Synvert::Application.configure do
  config.serve_static_files = false
jnd
    '}

    it 'converts' do
      FileUtils.mkdir_p 'config/environments'
      File.write 'config/application.rb', application_content
      File.write 'config/environments/production.rb', production_content
      @rewriter.process
      expect(File.read 'config/application.rb').to eq application_rewritten_content
      expect(File.read 'config/environments/production.rb').to eq production_rewritten_content
    end
  end
end
