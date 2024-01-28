# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails views from 3.2 to 4.0' do
  let(:rewriter_name) { 'rails/convert_views_3_2_to_4_0' }
  let(:fake_file_path) { 'app/views/posts/index.html.erb' }
  let(:test_content) { <<~EOS }
    <% @posts.each do |post| %>
      <%= link_to "delete", post_url(post), remote: true, confirm: "Are you sure to delete a post" %>
      <%= link_to "delete", post_url(post), remote: true, data: { foo: "bar" }, confirm: "Are you sure to delete a post" %>
    <% end %>
  EOS

  let(:test_rewritten_content) { <<~EOS }
    <% @posts.each do |post| %>
      <%= link_to "delete", post_url(post), remote: true, data: { confirm: "Are you sure to delete a post" } %>
      <%= link_to "delete", post_url(post), remote: true, data: { foo: "bar", confirm: "Are you sure to delete a post" } %>
    <% end %>
  EOS

  include_examples 'convertable'
end
