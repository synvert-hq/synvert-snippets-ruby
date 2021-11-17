# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Upgrade rails from 5.0 to 5.1' do
  let(:rewriter_name) { 'rails/upgrade_5_0_to_5_1' }
  let(:post_model_content) { <<~EOS }
    class Post < ApplicationRecord
      def configs
        rgb = HashWithIndifferentAccess.new
        rgb[:black] = "#000000"
        rgb = ActiveSupport::HashWithIndifferentAccess.new
        rgb[:white] = "#FFFFFF"

        Rails.application.config.secrets[:smtp_settings]["address"]
      end
    end
  EOS

  let(:post_model_rewritten_content) { <<~EOS }
    class Post < ApplicationRecord
      def configs
        rgb = ActiveSupport::HashWithIndifferentAccess.new
        rgb[:black] = "#000000"
        rgb = ActiveSupport::HashWithIndifferentAccess.new
        rgb[:white] = "#FFFFFF"

        Rails.application.config.secrets[:smtp_settings][:address]
      end
    end
  EOS

  let(:fake_file_paths) { ['app/models/post.rb'] }
  let(:test_contents) { [post_model_content] }
  let(:test_rewritten_contents) { [post_model_rewritten_content] }

  before { load_sub_snippets(%w[rails/convert_active_record_dirty_5_0_to_5_1]) }

  include_examples 'convertable with multiple files'
end
