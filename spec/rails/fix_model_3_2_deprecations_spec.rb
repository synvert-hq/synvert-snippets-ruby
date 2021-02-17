# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Fix rails model 3.2 deprecations' do
  let(:rewriter_name) { 'rails/fix_model_3_2_deprecations' }
  let(:fake_file_path) { 'app/models/project.rb' }
  let(:test_content) { '
class Project < ActiveRecord::Base
  set_table_name "project"
end
  '}
  let(:test_rewritten_content) { '
class Project < ActiveRecord::Base
  self.table_name = "project"
end
  '}

  include_examples 'convertable'
end
