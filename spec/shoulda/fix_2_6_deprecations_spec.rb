# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Fix shoulda 2.6 deprecations' do
  let(:rewriter_name) { 'shoulda/fix_2_6_deprecations' }

  context 'unit test methods' do
    let(:fake_file_path) { 'test/unit/post_test.rb' }
    let(:test_content) {
      '
class PostTest < ActiveSupport::TestCase
  should ensure_inclusion_of(:age).in_range(0..100)

  should ensure_exclusion_of(:age).in_range(30..60)
end
    '
    }
    let(:test_rewritten_content) {
      '
class PostTest < ActiveSupport::TestCase
  should validate_inclusion_of(:age).in_range(0..100)

  should validate_exclusion_of(:age).in_range(30..60)
end
    '
    }

    include_examples 'convertable'
  end
end
