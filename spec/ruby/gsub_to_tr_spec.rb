# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ruby converts gsub to tr' do
  let(:rewriter_name) { 'ruby/gsub_to_tr' }
  let(:test_content) { "'slug from title'.gsub(' ', '_')" }
  let(:test_rewritten_content) { "'slug from title'.tr(' ', '_')" }

  include_examples 'convertable'
end
