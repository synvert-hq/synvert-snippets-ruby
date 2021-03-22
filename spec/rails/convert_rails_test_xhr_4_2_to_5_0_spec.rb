# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert Foo to Bar' do
  let(:rewriter_name) { 'rails/convert_rails_test_xhr_4_2_to_5_0' }
  let(:fake_file_path) { 'test/functional/posts_controller_test.rb' }
  let(:test_content) { <<~EOS }
    class PostsControllerTest < ActionController::TestCase
      context "on XHR GET to show" do
        setup do
          xhr :get, :show
        end

        should respond_with :method_not_allowed
      end
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    class PostsControllerTest < ActionController::TestCase
      context "on XHR GET to show" do
        setup do
          get :show, xhr: true
        end

        should respond_with :method_not_allowed
      end
    end
  EOS

  include_examples 'convertable'
end
