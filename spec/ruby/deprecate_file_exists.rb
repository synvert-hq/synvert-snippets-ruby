# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deprecate File.exists?' do
  let(:rewriter_name) { 'ruby/deprecate_file_exists' }
  let(:fake_file_path) { 'foobar.rb' }
  let(:test_content) { 'File.exists?(path)' }
  let(:test_rewritten_content) { 'File.exist?(path)' }

  include_examples 'convertable'
end
