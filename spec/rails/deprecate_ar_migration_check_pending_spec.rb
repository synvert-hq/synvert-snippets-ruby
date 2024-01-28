# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deprecate ActiveRecord::Migration.check_pending!' do
  let(:rewriter_name) { 'rails/deprecate_ar_migration_check_pending' }
  let(:fake_file_path) { 'test/test_helper.rb' }
  let(:test_content) { 'ActiveRecord::Migration.check_pending!' }
  let(:test_rewritten_content) { '' }

  include_examples 'convertable'
end
