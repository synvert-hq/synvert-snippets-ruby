# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert RAILS_ROOT to Rails.root' do
  let(:rewriter_name) { 'rails/convert_rails_root' }
  let(:fake_file_path) { 'config/initializers/constant.rb' }
  let(:test_content) { <<~EOS }
    RAILS_ROOT
    File.join(RAILS_ROOT, "config", "database.yml")
    RAILS_ROOT + "/config/database.yml"
    "\#{RAILS_ROOT}/config/database.yml"
    File.exists?(RAILS_ROOT + "/config/database.yml")
  EOS

  let(:test_rewritten_content) { <<~EOS }
    Rails.root
    Rails.root.join("config", "database.yml")
    Rails.root.join("config/database.yml")
    Rails.root.join("config/database.yml")
    Rails.root.join("config/database.yml").exist?
  EOS

  include_examples 'convertable'
end
