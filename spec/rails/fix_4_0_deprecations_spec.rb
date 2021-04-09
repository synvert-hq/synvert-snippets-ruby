# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Fix rails 4.0 deprecations' do
  let(:rewriter_name) { 'rails/fix_4_0_deprecations' }
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
