# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert rails constants from 5.0 to 5.1' do
  let(:rewriter_name) { 'rails/convert_constants_5_0_to_5_1' }
  let(:fake_file_path) { 'app/models/post.rb' }
  let(:test_content) { <<~EOS }
    class Post < ApplicationRecord
      def configs
        rgb = HashWithIndifferentAccess.new
        rgb[:black] = "#000000"
        rgb = ActiveSupport::HashWithIndifferentAccess.new
        rgb[:white] = "#FFFFFF"
      end
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    class Post < ApplicationRecord
      def configs
        rgb = ActiveSupport::HashWithIndifferentAccess.new
        rgb[:black] = "#000000"
        rgb = ActiveSupport::HashWithIndifferentAccess.new
        rgb[:white] = "#FFFFFF"
      end
    end
  EOS

  include_examples 'convertable'
end
