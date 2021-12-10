# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Use string as class name' do
  let(:rewriter_name) { 'factory_bot/use_string_as_class_name' }
  let(:fake_file_path) { 'spec/factories/post.rb' }
  let(:test_content) { <<~EOS }
    FactoryBot.define do
      factory :admin, class: User do
        name { 'Admin' }
      end
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    FactoryBot.define do
      factory :admin, class: 'User' do
        name { 'Admin' }
      end
    end
  EOS

  include_examples 'convertable'
end
