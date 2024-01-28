# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails models from 3.2 to 4.0' do
  let(:rewriter_name) { 'rails/convert_models_3_2_to_4_0' }
  let(:fake_file_path) { 'app/models/post.rb' }
  let(:test_content) { <<~EOS }
    class Post < ActiveRecord::Base
      has_many :comments, dependent: :restrict

      def serialized_attrs
        self.serialized_attributes
      end
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class Post < ActiveRecord::Base
      has_many :comments, dependent: :restrict_with_exception

      def serialized_attrs
        self.class.serialized_attributes
      end
    end
  EOS

  include_examples 'convertable'
end
