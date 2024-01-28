# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails constants from 3.2 to 4.0' do
  let(:rewriter_name) { 'rails/convert_constants_3_2_to_4_0' }
  let(:fake_file_path) { 'test/unit/post_test.rb' }
  let(:test_content) { <<~EOS }
    require "test_helper"

    class PostTest < ActiveRecord::TestCase
      def constants
        [ActionController::Integration, ActionController::IntegrationTest, ActionController::PerformanceTest, ActionController::AbstractRequest,
        ActionController::Request, ActionController::AbstractResponse, ActionController::Response, ActionController::Routing]
      end
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    require "test_helper"

    class PostTest < ActiveSupport::TestCase
      def constants
        [ActionDispatch::Integration, ActionDispatch::IntegrationTest, ActionDispatch::PerformanceTest, ActionDispatch::Request,
        ActionDispatch::Request, ActionDispatch::Response, ActionDispatch::Response, ActionDispatch::Routing]
      end
    end
  EOS

  include_examples 'convertable'
end
