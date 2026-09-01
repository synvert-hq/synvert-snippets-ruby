# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Active Record serialize calls use keyword arguments' do
  let(:rewriter_name) { 'rails/serialize_use_keyword_arguments' }
  let(:fake_file_path) { 'app/models/user.rb' }
  let(:test_content) { <<~EOS }
    class User < ApplicationRecord
      serialize :preferences, Hash
      serialize :metadata, JSON
      serialize :settings, Array
      serialize :label, String
      serialize :value, Object
      serialize :preferences_with_default, Hash, default: {}
      serialize :metadata_with_default, JSON, default: {}
      serialize(:settings_with_default, ::Hash, default: {})
      serialize :payload, CustomCoder
      serialize :options, type: Hash, coder: YAML
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class User < ApplicationRecord
      serialize :preferences, type: Hash, coder: YAML
      serialize :metadata, coder: JSON
      serialize :settings, type: Array, coder: YAML
      serialize :label, type: String, coder: YAML
      serialize :value, type: Object, coder: YAML
      serialize :preferences_with_default, type: Hash, coder: YAML, default: {}
      serialize :metadata_with_default, coder: JSON, default: {}
      serialize(:settings_with_default, type: ::Hash, coder: YAML, default: {})
      serialize :payload, coder: CustomCoder
      serialize :options, type: Hash, coder: YAML
    end
  EOS

  include_examples 'convertable'
end
