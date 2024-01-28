# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails constants from 3.1 to  3.2' do
  let(:rewriter_name) { 'rails/convert_constants_3_1_to_3_2' }
  let(:fake_file_path) { 'app/controllers/application_controller.rb' }
  let(:test_content) { <<~EOS }
    class ApplicationController < ActionController::Base
      rescue_from ActionController::UnknownAction, :with => :render_404
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class ApplicationController < ActionController::Base
      rescue_from AbstractController::ActionNotFound, :with => :render_404
    end
  EOS

  include_examples 'convertable'
end
