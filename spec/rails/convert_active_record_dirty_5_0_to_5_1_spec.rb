# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert ActiveRecord::Dirty 5.0 to 5.1' do
  let(:rewriter_name) { 'rails/convert_active_record_dirty_5_0_to_5_1' }
  let(:fake_file_path) { 'app/models/post.rb' }
  let(:schema_content) { <<~EOS }
    ActiveRecord::Schema.define(version: 20140211112752) do
      create_table "posts", force: true do |t|
        t.string   "title"
        t.string   "summary"
        t.boolean  "status"
        t.timestamps
      end
    end
  EOS

  let(:test_content) { <<~EOS }
    class Post < ActiveRecord::Base
      before_create :call_before_create
      before_update :call_before_update, unless: :title_changed?
      before_save :call_before_save, if: -> { status_changed? || summary_changed? }
      after_create :call_after_create
      after_update :call_after_update, unless: :title_changed?
      after_save :call_after_save, if: -> { status_changed? || summary_changed? }

      before_save do
        if title_changed?
        end
      end

      def call_before_create
        if title_changed?
          changes
        end
      end

      def call_after_create
        if title_changed?
          changes
        end
      end
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class Post < ActiveRecord::Base
      before_create :call_before_create
      before_update :call_before_update, unless: :will_save_change_to_title?
      before_save :call_before_save, if: -> { will_save_change_to_status? || will_save_change_to_summary? }
      after_create :call_after_create
      after_update :call_after_update, unless: :saved_change_to_title?
      after_save :call_after_save, if: -> { saved_change_to_status? || saved_change_to_summary? }

      before_save do
        if will_save_change_to_title?
        end
      end

      def call_before_create
        if will_save_change_to_title?
          changes_to_save
        end
      end

      def call_after_create
        if saved_change_to_title?
          saved_changes
        end
      end
    end
  EOS

  before do
    FakeFS() do
      FileUtils.mkdir('db')
      File.write('db/schema.rb', schema_content)
    end
  end

  include_examples 'convertable'
end
