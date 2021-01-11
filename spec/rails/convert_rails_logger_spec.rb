require 'spec_helper'

RSpec.describe 'Upgrade RAILS_DEFAULT_LOGGER to Rails.logger' do
  let(:rewriter_name) { 'rails/convert_rails_logger' }
  let(:fake_file_path) { 'config/initializers/constant.rb' }
  let(:test_content) { "
RAILS_DEFAULT_LOGGER
::RAILS_DEFAULT_LOGGER
  "}
  let(:test_rewritten_content) { "
Rails.logger
Rails.logger
  "}

  include_examples 'convertable'
end
