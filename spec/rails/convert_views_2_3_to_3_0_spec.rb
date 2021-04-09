# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails views from 2.3 to 3.0' do
  let(:rewriter_name) { 'rails/convert_views_2_3_to_3_0' }
  let(:fake_file_path) { 'app/views/posts/_form.html.erb' }
  let(:test_content) { <<~EOS }
    <%= h user.login %>
    <%= post.title %>

    <% form_for post, :html => {:id => 'post-form'} do |post_form| %>
      <% fields_for :author, post.author do |author_form| %>
      <% end %>
    <% end %>
    <%= form_for post do |f| %>
    <% end %>
  EOS

  let(:test_rewritten_content) { <<~EOS }
    <%= user.login %>
    <%= post.title %>

    <%= form_for post, :html => {:id => 'post-form'} do |post_form| %>
      <%= fields_for :author, post.author do |author_form| %>
      <% end %>
    <% end %>
    <%= form_for post do |f| %>
    <% end %>
  EOS

  include_examples 'convertable'
end
