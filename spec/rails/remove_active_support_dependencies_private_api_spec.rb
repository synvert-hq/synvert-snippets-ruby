# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Remove ActiveSupport::Dependencies private api' do
  let(:rewriter_name) { 'rails/remove_active_support_dependencies_private_api' }
  let(:fake_file_path) { 'app/models/user.rb' }
  let(:test_content) { <<~EOS }
    ActiveSupport::Dependencies.constantize("User")
    ActiveSupport::Dependencies.safe_constantize("User")
  EOS

  let(:test_rewritten_content) { <<~EOS }
    "User".constantize
    "User".safe_constantize
  EOS

  include_examples 'convertable'
end
