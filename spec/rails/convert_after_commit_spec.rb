# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert after_commit' do
  let(:rewriter_name) { 'rails/convert_after_commit' }
  let(:fake_file_path) { 'app/models/post.rb' }
  let(:test_content) { <<~EOS }
    class Post < ApplicationRecord
      after_commit :add_to_index_later, on: :create, if: :can_add?
      after_commit :update_in_index_later, on: :update
      after_commit :remove_from_index_later, on: :destroy
      after_commit :add_to_index_later, on: [:create], if: :can_add?
      after_commit :update_in_index_later, on: [:update]
      after_commit :save_to_index_later, on: [:create, :update]
      after_commit :save_to_index_later, on: [:update, :create]
      after_commit :remove_from_index_later, on: [:destroy]
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class Post < ApplicationRecord
      after_create_commit :add_to_index_later, if: :can_add?
      after_update_commit :update_in_index_later
      after_destroy_commit :remove_from_index_later
      after_create_commit :add_to_index_later, if: :can_add?
      after_update_commit :update_in_index_later
      after_save_commit :save_to_index_later
      after_save_commit :save_to_index_later
      after_destroy_commit :remove_from_index_later
    end
  EOS

  include_examples 'convertable'
end
