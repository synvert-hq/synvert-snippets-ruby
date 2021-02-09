require 'spec_helper'

RSpec.describe 'Convert update_attributes to update' do
  let(:rewriter_name) { 'rails/convert_update_attributes_to_update' }
  let(:fake_file_path) { 'app/model/user.rb' }
  let(:test_content) {
    "
    class User < ActiveRecord::Base
      def test
        update_attributes(title: 'new')
        self.update_attributes!(title: 'new')
        self.update(title: 'new')
      end
    end
  "
  }
  let(:test_rewritten_content) {
    "
    class User < ActiveRecord::Base
      def test
        update(title: 'new')
        self.update!(title: 'new')
        self.update(title: 'new')
      end
    end
  "
  }

  include_examples 'convertable'
end
