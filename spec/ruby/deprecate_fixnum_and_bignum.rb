# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deprecate Fixnum and Bignum' do
  let(:rewriter_name) { 'ruby/deprecate_fixnum_and_bignum' }
  let(:fake_file_path) { 'foobar.rb' }
  let(:test_content) { <<~EOS }
    Fixnum
    Bignum
  EOS
  let(:test_rewritten_content) { <<~EOS }
    Integer
    Integer
  EOS

  include_examples 'convertable'
end
