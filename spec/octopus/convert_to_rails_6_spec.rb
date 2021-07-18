# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert to rails 6' do
  let(:rewriter_name) { 'octopus/convert_to_rails_6' }
  let(:fake_file_path) { 'app/models/user.rb' }
  let(:test_content) { <<~EOS }
    messages = self.using(:slave).messages

    def my_messages
      self.using(:slave).messages
    end
  EOS
  let(:test_rewritten_content) { <<~EOS }
    messages = ActiveRecord::Base.connected_to(role: :reading) do
      self.messages
    end

    def my_messages
      ActiveRecord::Base.connected_to(role: :reading) do
        self.messages
      end
    end
  EOS

  include_examples 'convertable'
end