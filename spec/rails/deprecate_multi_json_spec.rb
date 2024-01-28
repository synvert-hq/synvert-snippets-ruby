# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Replace multi_json with json' do
  let(:rewriter_name) { 'rails/deprecate_multi_json' }
  let(:fake_file_path) { 'app/models/post.rb' }
  let(:test_content) { <<~EOS }
    class Post < ActiveRecord::Base
      def test
        json = MultiJson.dump self
        MultiJson.load json
      end
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    class Post < ActiveRecord::Base
      def test
        json = self.to_json
        JSON.parse json
      end
    end
  EOS

  include_examples 'convertable'
end
