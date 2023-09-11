# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Test request methods use keyword arguments' do
  let(:rewriter_name) { 'rails/test_request_methods_use_keyword_arguments' }

  context 'functional test' do
    let(:fake_file_path) { 'test/functional/posts_controller_test.rb' }
    let(:test_content) { <<~EOS }
      class PostsControllerTest < ActionController::TestCase
        def test_index
          options = { params: { foo: 'bar' } }
          get :index, options
        end

        def test_create
          options = { params: { foo: 'bar' } }
          post :create, options
        end

        def test_destroy
          options = { params: { foo: 'bar' } }
          delete :destroy, options
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      class PostsControllerTest < ActionController::TestCase
        def test_index
          options = { params: { foo: 'bar' } }
          get :index, **options
        end

        def test_create
          options = { params: { foo: 'bar' } }
          post :create, **options
        end

        def test_destroy
          options = { params: { foo: 'bar' } }
          delete :destroy, **options
        end
      end
    EOS

    include_examples 'convertable'
  end

  context 'integration test' do
    let(:fake_file_path) { 'spec/integration/posts_controller_spec.rb' }
    let(:test_content) { <<~EOS }
      RSpec.describe '/posts' do
        it 'tests index' do
          @options = { headers: { 'HTTP_AUTHORIZATION' => 'fake' } }
          get '/posts', @options
        end

        it 'tests create' do
          @options = { headers: { 'HTTP_AUTHORIZATION' => 'fake' } }
          post '/posts', @options
        end

        it 'tests delete' do
          @options = { headers: { 'HTTP_AUTHORIZATION' => 'fake' } }
          delete '/posts/1', @options
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      RSpec.describe '/posts' do
        it 'tests index' do
          @options = { headers: { 'HTTP_AUTHORIZATION' => 'fake' } }
          get '/posts', **@options
        end

        it 'tests create' do
          @options = { headers: { 'HTTP_AUTHORIZATION' => 'fake' } }
          post '/posts', **@options
        end

        it 'tests delete' do
          @options = { headers: { 'HTTP_AUTHORIZATION' => 'fake' } }
          delete '/posts/1', **@options
        end
      end
    EOS

    include_examples 'convertable'
  end
end
