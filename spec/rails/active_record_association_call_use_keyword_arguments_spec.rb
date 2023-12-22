# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ActiveRecord assocation call to use keyword arguments' do
  let(:rewriter_name) { 'rails/active_record_association_call_use_keyword_arguments' }
  let(:fake_file_path) { 'app/models/user.rb' }
  let(:test_content) { <<~EOS }
    class User < ApplicationRecord
      has_many :posts, { dependent: :destroy }
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class User < ApplicationRecord
      has_many :posts, dependent: :destroy
    end
  EOS

  include_examples 'convertable'
end
