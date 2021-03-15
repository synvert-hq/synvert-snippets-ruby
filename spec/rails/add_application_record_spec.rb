# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Add ApplicationRecord' do
  let(:rewriter_name) { 'rails/add_application_record' }

  context 'add application_record' do
    let(:fake_file_path) { 'app/models/application_record.rb' }
    let(:test_content) { nil }
    let(:test_rewritten_content) { <<~EOS }
      class ApplicationRecord < ActiveRecord::Base
        self.abstract_class = true
      end
      EOS

    include_examples 'convertable'
  end

  context 'rename ActiveRecord::Base' do
    let(:fake_file_path) { 'app/models/post.rb' }
    let(:test_content) { <<~EOS }
      class Post < ActiveRecord::Base
      end
      EOS

    let(:test_rewritten_content) { <<~EOS }
      class Post < ApplicationRecord
      end
      EOS

    include_examples 'convertable'
  end
end
