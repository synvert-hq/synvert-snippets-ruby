# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails request methods from 4.2 to 5.0' do
  let(:rewriter_name) { 'rails/convert_rails_test_request_methods_4_2_to_5_0' }

  context 'functional test' do
    let(:fake_file_path) { 'test/functional/posts_controller_test.rb' }
    let(:test_content) { <<~EOS }
      class PostsControllerTest < ActionController::TestCase
        def test_show
          get :show, { id: user.id, format: :json }, { admin: user.admin? }, { notice: 'Welcome' }
        end

        def test_index
          get :index, params: { query: 'test' }
        end

        def test_create
          post :create, name: 'user'
        end

        def test_destroy
          delete :destroy, { id: user.id }, { admin: user.admin? }
        end

        def test_xhr
          xhr :get, :test
          xhr :post, :test, foo: 'bar'
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      class PostsControllerTest < ActionController::TestCase
        def test_show
          get :show, params: { id: user.id }, session: { admin: user.admin? }, flash: { notice: 'Welcome' }, as: :json
        end

        def test_index
          get :index, params: { query: 'test' }
        end

        def test_create
          post :create, params: { name: 'user' }
        end

        def test_destroy
          delete :destroy, params: { id: user.id }, session: { admin: user.admin? }
        end

        def test_xhr
          get :test, xhr: true
          post :test, params: { foo: 'bar' }, xhr: true
        end
      end
    EOS

    include_examples 'convertable'
  end

  context 'integration test' do
    let(:fake_file_path) { 'spec/integration/posts_controller_spec.rb' }
    let(:test_content) { <<~EOS }
      RSpec.describe '/posts' do
        it 'tests show' do
          get '/posts/1', user_id: user.id
        end

        it 'tests index' do
          get '/posts', headers: { 'HTTP_AUTHORIZATION' => 'fake' }
        end

        it 'tests create' do
          post '/posts', { title: 'test' }, { 'HTTP_AUTHORIZATION' => 'fake' }
        end

        it 'tests delete' do
          delete '/posts/1', nil, { 'HTTP_AUTHORIZATION' => 'fake' }
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      RSpec.describe '/posts' do
        it 'tests show' do
          get '/posts/1', params: { user_id: user.id }
        end

        it 'tests index' do
          get '/posts', headers: { 'HTTP_AUTHORIZATION' => 'fake' }
        end

        it 'tests create' do
          post '/posts', params: { title: 'test' }, headers: { 'HTTP_AUTHORIZATION' => 'fake' }
        end

        it 'tests delete' do
          delete '/posts/1', headers: { 'HTTP_AUTHORIZATION' => 'fake' }
        end
      end
    EOS

    include_examples 'convertable'
  end
end
