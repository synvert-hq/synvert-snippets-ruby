require 'spec_helper'

describe 'Upgrade rails from 3.1 to 3.2' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/upgrade_3_1_to_3_2.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:development_content) {'''
Synvert::Application.configure do
end
    '''}
    let(:development_rewritten_content) {'''
Synvert::Application.configure do
  config.active_record.mass_assignment_sanitizer = :strict
  config.active_record.auto_explain_threshold_in_seconds = 0.5
end
    '''}
    let(:test_content) {'''
Synvert::Application.configure do
end
    '''}
    let(:test_rewritten_content) {'''
Synvert::Application.configure do
  config.active_record.mass_assignment_sanitizer = :strict
end
    '''}
    let(:project_content) {'''
class Project < ActiveRecord::Base
  set_table_name "project"
end
    '''}
    let(:project_rewritten_content) {'''
class Project < ActiveRecord::Base
  self.table_name = "project"
end
    '''}
    let(:application_controller_content) {'''
class ApplicationController < ActionController::Base
  rescue_from ActionController::UnknownAction, :with => :render_404
end
    '''}
    let(:application_controller_rewritten_content) {'''
class ApplicationController < ActionController::Base
  rescue_from AbstractController::ActionNotFound, :with => :render_404
end
    '''}

    it 'converts' do
      FileUtils.mkdir_p 'config/environments'
      FileUtils.mkdir_p 'app/models'
      FileUtils.mkdir_p 'app/controllers'
      File.write 'config/environments/development.rb', development_content
      File.write 'config/environments/test.rb', test_content
      File.write 'app/models/project.rb', project_content
      File.write 'app/controllers/application_controller.rb', application_controller_content
      @rewriter.process
      expect(File.read 'config/environments/development.rb').to eq development_rewritten_content
      expect(File.read 'config/environments/test.rb').to eq test_rewritten_content
      expect(File.read 'app/models/project.rb').to eq project_rewritten_content
      expect(File.read 'app/controllers/application_controller.rb').to eq application_controller_rewritten_content
    end
  end
end
