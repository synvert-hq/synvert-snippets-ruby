# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Add ActiveRecord::Migration rails version' do
  let(:rewriter_name) { 'rails/add_active_record_migration_rails_version' }
  let(:fake_file_path) { 'db/migrate/20180101000000_create_users.rb' }
  let(:test_content) { <<~EOS }
    class CreateUsers < ActiveRecord::Migration
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class CreateUsers < ActiveRecord::Migration[4.2]
    end
  EOS

  include_examples 'convertable'
end
