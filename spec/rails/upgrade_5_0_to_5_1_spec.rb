# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Upgrade rails from 5.0 to 5.1' do
  let(:rewriter_name) { 'rails/upgrade_5_0_to_5_1' }
  let(:config_application_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.load_defaults 5.0
      end
    end
  EOS
  let(:config_application_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.load_defaults 5.1
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

  let(:fake_file_paths) { ['config/application.rb', 'app/models/post.rb'] }
  let(:test_contents) { [config_application_content, post_model_content] }
  let(:test_rewritten_contents) { [config_application_rewritten_content, post_model_rewritten_content] }

  before do
    load_sub_snippets(%w[rails/convert_active_record_dirty_5_0_to_5_1])
    load_helpers(%w[helpers/set_rails_load_defaults])
  end

  include_examples 'convertable with multiple files'
end
