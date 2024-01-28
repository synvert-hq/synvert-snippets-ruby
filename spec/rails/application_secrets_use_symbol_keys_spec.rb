# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'application.secrets uses symbol keys' do
  let(:rewriter_name) { 'rails/application_secrets_use_symbol_keys' }
  let(:fake_file_path) { 'app/models/post.rb' }
  let(:test_content) { <<~EOS }
    class Post < ApplicationRecord
      def configs
        Rails.application.config.secrets["smtp_settings"]["address"]
      end
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    class Post < ApplicationRecord
      def configs
        Rails.application.config.secrets[:smtp_settings][:address]
      end
    end
  EOS

  include_examples 'convertable'
end
