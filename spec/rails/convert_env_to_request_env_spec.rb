# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert env to request.env' do
  let(:rewriter_name) { 'rails/convert_env_to_request_env' }
  let(:fake_file_path) { 'app/controllers/posts_controller.rb' }
  let(:test_content) { <<~EOS }
    class OmniauthCallbacksController < ApplicationController
      def create
        env['omniauth.auth']
      end
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class OmniauthCallbacksController < ApplicationController
      def create
        request.env['omniauth.auth']
      end
    end
  EOS

  include_examples 'convertable'
end
