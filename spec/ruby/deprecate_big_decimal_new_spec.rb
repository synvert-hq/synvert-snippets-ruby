# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deprecate BigDecimal.new' do
  let(:rewriter_name) { 'ruby/deprecate_big_decimal_new' }
  let(:fake_file_path) { 'foobar.rb' }
  let(:test_content) { 'BigDecimal.new("1.1")' }
  let(:test_rewritten_content) { 'BigDecimal("1.1")' }

  include_examples 'convertable'
end
