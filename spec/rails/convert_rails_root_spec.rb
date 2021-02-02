require 'spec_helper'

RSpec.describe 'Convert RAILS_ROOT to Rails.root' do
  let(:rewriter_name) { 'rails/convert_rails_root' }
  let(:fake_file_path) { 'config/initializers/constant.rb' }
  let(:test_content) {
    '
RAILS_ROOT
::RAILS_ROOT
File.join(RAILS_ROOT, "config", "database.yml")
RAILS_ROOT + "/config/database.yml"
"#{RAILS_ROOT}/config/database.yml"
File.exists?(RAILS_ROOT + "/config/database.yml")
  '
  }
  let(:test_rewritten_content) {
    '
Rails.root
Rails.root
Rails.root.join("config", "database.yml")
Rails.root.join("config/database.yml")
Rails.root.join("config/database.yml")
Rails.root.join("config/database.yml").exist?
  '
  }

  include_examples 'convertable'
end
