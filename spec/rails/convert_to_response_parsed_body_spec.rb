# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert to response.parsed_body' do
  let(:rewriter_name) { 'rails/convert_to_response_parsed_body' }

  context 'rails test' do
    let(:fake_file_path) { 'test/functional/posts_controller_test.rb' }
    let(:test_content) { <<~EOS }
      class PostsControllerTest < ActionController::TestCase
        def setup
          @json_body = JSON.parse(@response.body)
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      class PostsControllerTest < ActionController::TestCase
        def setup
          @json_body = @response.parsed_body
        end
      end
    EOS

    include_examples 'convertable'
  end

  context 'rspec test' do
    let(:fake_file_path) { 'spec/controllers/posts_controller_spec.rb' }
    let(:test_content) { <<~EOS }
      RSpec.describe PostsController, type: :controller do
        before do
          @json_body = JSON.parse(response.body)
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      RSpec.describe PostsController, type: :controller do
        before do
          @json_body = response.parsed_body
        end
      end
    EOS

    include_examples 'convertable'
  end
end
