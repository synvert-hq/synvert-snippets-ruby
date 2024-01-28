# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Uses ActiveStorage image_processing macros' do
  let(:rewriter_name) { 'rails/use_active_storage_image_processing_macros' }
  let(:fake_file_path) { 'app/models/item.rb' }
  let(:test_content) { <<~EOS }
    class Item < ApplicationRecord
      def resize
        video.preview(resize: "100x100")
        video.preview(resize: "100x100>")
        video.preview(resize: "100x100^")
      end
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class Item < ApplicationRecord
      def resize
        video.preview(resize_to_fit: [100, 100])
        video.preview(resize_to_limit: [100, 100])
        video.preview(resize_to_fill: [100, 100])
      end
    end
  EOS

  include_examples 'convertable'
end
