# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deprecate Dir.exists?' do
  let(:rewriter_name) { 'ruby/deprecate_dir_exists' }
  let(:fake_file_path) { 'foobar.rb' }
  let(:test_content) { 'Dir.exists?(path)' }
  let(:test_rewritten_content) { 'Dir.exist?(path)' }

  include_examples 'convertable'
end
