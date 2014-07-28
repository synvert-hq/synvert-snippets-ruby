# encoding: utf-8

require 'spec_helper'

describe 'Convert rails views from 2.3 to 3.0' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/convert_views_2_3_to_3_0.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:posts_show_content) {"""
  <%= h user.login %>
  <%= post.title %>

  <% form_for post, :html => {:id => 'post-form'} do |f| %>
  <% end %>
  <%= form_for post do |f| %>
  <% end %>
    """}
    let(:posts_show_rewritten_content) {"""
  <%= user.login %>
  <%= post.title %>

  <%= form_for post, :html => {:id => 'post-form'} do |f| %>
  <% end %>
  <%= form_for post do |f| %>
  <% end %>
    """}

    it 'converts' do
      FileUtils.mkdir_p 'app/views/posts'
      File.write 'app/views/posts/show.html.erb', posts_show_content
      @rewriter.process
      expect(File.read 'app/views/posts/show.html.erb').to eq posts_show_rewritten_content
    end
  end
end
