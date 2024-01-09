# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert Foo to Bar' do
  let(:rewriter_name) { 'rails/migrate-ujs-to-turbo' }
  let(:fake_file_path) { 'app/views/posts/index.html.erb' }
  let(:test_content) { <<~EOS }
    <%= link_to "Destroy", post_path(post), method: :delete %>
    <%= link_to "Destroy", post_path(post), method: :delete, data: { confirm: 'Are you sure?' } %>
    <%= submit_tag "Create", data: { disable_with: "Submitting..." } %>
  EOS
  let(:test_rewritten_content) { <<~EOS }
    <%= link_to "Destroy", post_path(post), data: { turbo_method: :delete } %>
    <%= link_to "Destroy", post_path(post), data: { turbo_method: :delete, turbo_confirm: 'Are you sure?' } %>
    <%= submit_tag "Create", data: { turbo_submits_with: "Submitting..." } %>
  EOS

  include_examples 'convertable'
end
