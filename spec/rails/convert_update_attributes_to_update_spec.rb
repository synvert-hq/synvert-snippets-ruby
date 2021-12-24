# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert update_attributes to update' do
  let(:rewriter_name) { 'rails/convert_update_attributes_to_update' }
  let(:fake_file_path) { 'app/model/user.rb' }
  let(:test_content) { <<~EOS }
    class User < ActiveRecord::Base
      def test
        update_attributes(title: 'new')
        self.update_attributes!(title: 'new')
        self.update(title: 'new')

        role&.update_attributes(admin: false)
      end
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class User < ActiveRecord::Base
      def test
        update(title: 'new')
        self.update!(title: 'new')
        self.update(title: 'new')

        role&.update(admin: false)
      end
    end
  EOS

  include_examples 'convertable'
end
