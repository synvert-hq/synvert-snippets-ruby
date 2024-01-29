# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Update ActiveStorage variant argument' do
  let(:rewriter_name) { 'rails/update_active_storage_variant_argument' }
  let(:fake_file_path) { 'app/models/item.rb' }
  let(:test_content) { <<~EOS }
    class Item < ApplicationRecord
      def resize
        image.variant(resize: "100x")
        image.variant(crop: "1920x1080+0+0")
        image.variant(resize_and_pad: [300, 300])
        image.variant(monochrome: true)
      end
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class Item < ApplicationRecord
      def resize
        image.variant(resize_to_limit: [100, nil])
        image.variant(crop: [0, 0, 1920, 1080])
        image.variant(resize_and_pad: [300, 300, background: [255]])
        image.variant(colourspace: "b-w")
      end
    end
  EOS

  include_examples 'convertable'
end
