# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Ruby Iconv#iconv to String#encode' do
  let(:rewriter_name) { 'ruby/iconv_to_encode' }

  describe 'basic case' do
    let(:test_content) { "Iconv.new('Windows-1252','utf-8').iconv('some string')"}
    let(:test_rewritten_content) { "'some string'.force_encoding('utf-8').encode('Windows-1252')" }

    include_examples 'convertable'
  end

  describe 'with iconv ignored option' do
    let(:test_content) { "Iconv.new('Windows-1252//IGNORE','utf-8//IGNORE').iconv('some string')"}
    let(:test_rewritten_content) { "'some string'.force_encoding('utf-8').encode('Windows-1252', invalid: :replace, undef: :replace)" }

    include_examples 'convertable'
  end

  describe 'case with encodings set in vars' do
    let(:test_content) { 'Iconv.new(to_charset, from_charset).iconv(line)' }
    let(:test_rewritten_content) { 'line.force_encoding(from_charset).encode(to_charset)' }

    include_examples 'convertable'
  end

  describe 'remove iconv requires' do
    let(:test_content) { "
      require 'iconv'
      require 'foo'
    " }
    let(:test_rewritten_content) { "
      require 'foo'
    " }

    include_examples 'convertable'
  end
end
