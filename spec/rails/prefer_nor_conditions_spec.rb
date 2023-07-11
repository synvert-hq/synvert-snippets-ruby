# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Prefer NOR conditions' do
  let(:rewriter_name) { 'rails/prefer_nor_conditions' }
  let(:fake_file_path) { 'app/models/user.rb' }
  let(:test_content) { <<~EOS }
    where.not(first_name: nil, last_name: nil, email: nil)
  EOS

  let(:test_rewritten_content) { <<~EOS }
    where.not(first_name: nil).where.not(last_name: nil).where.not(email: nil)
  EOS

  include_examples 'convertable'
end
