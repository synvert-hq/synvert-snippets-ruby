# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Minitest converts hooks_super' do
  let(:rewriter_name) { 'minitest/hooks_super' }
  let(:fake_file_path) { 'test/units/post_test.rb' }
  let(:test_content) { <<~EOS }
    class TestMeme < Minitest::Test
      include MyHelper

      def setup
        do_something
      end

      def teardown
        clean_something
      end
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    class TestMeme < Minitest::Test
      include MyHelper

      def setup
        super
        do_something
      end

      def teardown
        clean_something
        super
      end
    end
  EOS

  include_examples 'convertable'
end
