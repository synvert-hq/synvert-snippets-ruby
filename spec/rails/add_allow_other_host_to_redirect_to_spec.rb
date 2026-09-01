# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Add allow_other_host to redirect_to calls' do
  let(:rewriter_name) { 'rails/add_allow_other_host_to_redirect_to' }
  let(:fake_file_path) { 'app/controllers/callbacks_controller.rb' }
  let(:test_content) { <<~RUBY }
    class CallbacksController < ApplicationController
      def create
        redirect_to callback_url
        redirect_to(callback_url, status: :see_other)
        redirect_to callback_url, allow_other_host: true
      end
    end
  RUBY
  let(:test_rewritten_content) { <<~RUBY }
    class CallbacksController < ApplicationController
      def create
        redirect_to callback_url, allow_other_host: true
        redirect_to(callback_url, status: :see_other, allow_other_host: true)
        redirect_to callback_url, allow_other_host: true
      end
    end
  RUBY

  include_examples 'convertable'
end
