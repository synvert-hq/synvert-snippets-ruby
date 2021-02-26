# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Fix rails controller 3.2 deprecations' do
  let(:rewriter_name) { 'rails/fix_controller_3_2_deprecations' }
  let(:fake_file_path) { 'app/controllers/application_controller.rb' }
  let(:test_content) {
    '
class ApplicationController < ActionController::Base
  rescue_from ActionController::UnknownAction, :with => :render_404
end
  '
  }
  let(:test_rewritten_content) {
    '
class ApplicationController < ActionController::Base
  rescue_from AbstractController::ActionNotFound, :with => :render_404
end
  '
  }

  include_examples 'convertable'
end
