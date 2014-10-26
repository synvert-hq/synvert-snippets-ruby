require 'spec_helper'

RSpec.describe 'Upgrade rails from 2.3 to 3.0' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/upgrade_2_3_to_3_0.rb')
    @rewriter = eval(File.read(rewriter_path))
    %w(convert_rails_env convert_rails_root convert_rails_logger
       convert_mailers_2_3_to_3_0 convert_models_2_3_to_3_0
       convert_routes_2_3_to_3_0 convert_views_2_3_to_3_0).each do |sub_snippet|
      sub_rewriter_path = File.join(File.dirname(__FILE__), "../../lib/rails/#{sub_snippet}.rb")
      eval(File.read(sub_rewriter_path))
    end
  end

  describe 'with fakefs', fakefs: true do
    let(:application_controller_content) {'
class ApplicationController < ActionController::Base
  filter_parameter_logging :password, :password_confirmation
end
    '}
    let(:application_content) {'
module Synvert
  class Application < Rails::Application
  end
end
    '}
    let(:application_controller_rewritten_content) {'
class ApplicationController < ActionController::Base
end
    '}
    let(:application_rewritten_content) {'
module Synvert
  class Application < Rails::Application
    config.filter_parameters += [:password, :password_confirmation]
  end
end
    '}
    it 'converts' do
      FileUtils.mkdir_p 'config'
      FileUtils.mkdir_p 'app/controllers'
      File.write 'config/application.rb', application_content
      File.write 'app/controllers/application_controller.rb', application_controller_content
      @rewriter.process
      expect(File.read 'config/application.rb').to eq application_rewritten_content
      expect(File.read 'app/controllers/application_controller.rb').to eq application_controller_rewritten_content
    end
  end
end
