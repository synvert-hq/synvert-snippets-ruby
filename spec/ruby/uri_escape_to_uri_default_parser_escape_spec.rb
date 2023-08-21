# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Uses URI::DEFAULT_PARSER.escape instead of URI.escape' do
  let(:rewriter_name) { 'ruby/uri_escape_to_uri_default_parser_escape' }

  let(:test_content) { <<~EOS }
    URI.escape(url)
  EOS

  let(:test_rewritten_content) { <<~EOS }
    URI::DEFAULT_PARSER.escape(url)
  EOS

  include_examples 'convertable'
end
