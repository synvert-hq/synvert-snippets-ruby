# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails routes from 2.3 to 3.0' do
  let(:rewriter_name) { 'rails/convert_routes_2_3_to_3_0' }
  let(:fake_file_path) { 'config/routes.rb' }
  let(:test_content) { '
ActionController::Routing::Routes.draw do |map|
  map.connect "/main/:id", :controller => "main", :action => "home"

  map.admin_signup "/admin_signup", :controller => "admin_signup", :action => "index", :method => "post"
  map.phoenix "/phoenix/:action", :controller => "phoenix"

  map.resources :posts, :collection => { :generate_csv => [:get, :post], :generate_pdf => :any }, :member => {:activate => :post}, :controller => "admin/posts", :path_prefix => "/admin" do |posts|
    posts.resources :comments
    posts.resource :author
  end
  map.resources :questions, :collection => [:generate_csv], :member => :activate

  map.namespace :admin do |admin|
    admin.resources :users
  end

  map.with_options :controller => "manage" do |manage|
    manage.manage_index "manage_index", :action => "index", :conditions => {:subdomain => "manage"}
    manage.manage_intro "manage_intro", :action => "intro", :conditions => {:subdomain => "manage"}
  end

  map.admin "/admin", :controller => "admin/staff"

  map.connect "audio/:action/:id", :controller => "audio"
  map.connect "video/:action", :controller => "video"
  map.connect "/:controller/:action/:id"

  map.root :controller => "home", :action => "index"
end
  '}
  let(:test_rewritten_content) { '
ActionController::Routing::Routes.draw do |map|
  match "/main/:id", :to => "main#home"

  post "/admin_signup", :to => "admin_signup#index", :as => "admin_signup"
  match "/phoenix/:action", :controller => "phoenix"

  resources :posts, :controller => "admin/posts", :path_prefix => "/admin" do
    collection do
      get :generate_csv
      post :generate_csv
      match :generate_pdf
    end
    member do
      post :activate
    end
    resources :comments
    resource :author
  end
  resources :questions do
    collection do
      match :generate_csv
    end
    member do
      match :activate
    end
  end

  namespace :admin do
    resources :users
  end

  match "manage_index", :to => "manage#index", :constraints => {:subdomain => "manage"}, :as => "manage_index"
  match "manage_intro", :to => "manage#intro", :constraints => {:subdomain => "manage"}, :as => "manage_intro"

  match "/admin", :to => "admin/staff#index", :as => "admin"

  match "audio(/:action(/:id))(.:format)", :controller => "audio"
  match "video(/:action)(.:format)", :controller => "video"
  match "/:controller(/:action(/:id))(.:format)"

  root :to => "home#index"
end
  '}

  include_examples 'convertable'
end
