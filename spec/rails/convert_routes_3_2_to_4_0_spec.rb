# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails routes from 3.2 to 4.0' do
  let(:rewriter_name) { 'rails/convert_routes_3_2_to_4_0' }
  let(:fake_file_path) { 'config/routes.rb' }
  let(:test_content) { <<~EOS }
    Synvert::Application.routes.draw do
      get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
      match '/' => 'root#index'
      match 'new', to: 'episodes#new'
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    Synvert::Application.routes.draw do
      get 'こんにちは', controller: 'welcome', action: 'index'
      get '/' => 'root#index'
      get 'new', to: 'episodes#new'
    end
  EOS

  include_examples 'convertable'
end
