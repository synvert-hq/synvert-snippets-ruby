# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Explicitly render with formats' do
  let(:rewriter_name) { 'rails/explicitly-render-with-formats' }
  let(:fake_file_path) { 'app/controllers/foo_controller.rb' }
  let(:test_content) { "render template: 'index.json'" }
  let(:test_rewritten_content) { "render template: 'index', formats: [:json]" }

  include_examples 'convertable'
end
