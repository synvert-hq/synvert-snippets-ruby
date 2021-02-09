# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'FactoryGirl uses short synax' do
  let(:rewriter_name) { 'factory_girl/use_short_syntax' }

  context 'rspec' do
    context 'spec_helper' do
      let(:fake_file_path) { 'spec/spec_helper.rb' }
      let(:test_content) { '
  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered = true
  end
      '}
      let(:test_rewritten_content) { '
  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered = true
  end
      '}

      include_examples 'convertable'
    end

    context 'unit test' do
      let(:fake_file_path) { 'spec/models/post_spec.rb' }
      let(:test_content) { '
  describe Post do
    it "tests post" do
      post1 = FactoryGirl.create(:post)
      post2 = FactoryGirl.build(:post)
      post_attributes = FactoryGirl.attributes_for(:post)
      post3 = FactoryGirl.build_stubbed(:post)
      posts1 = FactoryGirl.create_list(:post, 2)
      posts2 = FactoryGirl.build_list(:post, 2)
      posts3 = FactoryGirl.create_pair(:post)
      posts4 = FactoryGirl.build_pair(:post)
    end
  end
      '}
      let(:test_rewritten_content) { '
  describe Post do
    it "tests post" do
      post1 = create(:post)
      post2 = build(:post)
      post_attributes = attributes_for(:post)
      post3 = build_stubbed(:post)
      posts1 = create_list(:post, 2)
      posts2 = build_list(:post, 2)
      posts3 = create_pair(:post)
      posts4 = build_pair(:post)
    end
  end
      '}

      include_examples 'convertable'
    end
  end

  context 'test/unit' do
    context 'test_helper' do
      let(:fake_file_path) { 'test/test_helper.rb' }
      let(:test_content) { '
    class ActiveSupport::TestCase
    end
      '}
      let(:test_rewritten_content) { '
    class ActiveSupport::TestCase
      include FactoryGirl::Syntax::Methods
    end
      '}

      include_examples 'convertable'
    end

    context 'unit test' do
      let(:fake_file_path) { 'test/unit/post_test.rb' }
      let(:test_content) { '
  test "post" do
    post1 = FactoryGirl.create(:post)
    post2 = FactoryGirl.build(:post)
    post_attributes = FactoryGirl.attributes_for(:post)
    post3 = FactoryGirl.build_stubbed(:post)
    posts1 = FactoryGirl.create_list(:post, 2)
    posts2 = FactoryGirl.build_list(:post, 2)
    posts3 = FactoryGirl.create_pair(:post)
    posts4 = FactoryGirl.build_pair(:post)
  end
      '}
      let(:test_rewritten_content) { '
  test "post" do
    post1 = create(:post)
    post2 = build(:post)
    post_attributes = attributes_for(:post)
    post3 = build_stubbed(:post)
    posts1 = create_list(:post, 2)
    posts2 = build_list(:post, 2)
    posts3 = create_pair(:post)
    posts4 = build_pair(:post)
  end
      '}

      include_examples 'convertable'
    end
  end

  context 'cucumber' do
    context 'features/support/env' do
      let(:fake_file_path) { 'features/support/env.rb' }
      let(:test_content) { '
  require "cucumber/rails"
      '}
      let(:test_rewritten_content) { '
  require "cucumber/rails"
  World(FactoryGirl::Syntax::Methods)
      '}

      include_examples 'convertable'
    end

    context 'step definition' do
      let(:fake_file_path) { 'features/step_definitions/post_steps.rb' }
      let(:test_content) { '
  test "post" do
    post1 = FactoryGirl.create(:post)
    post2 = FactoryGirl.build(:post)
    post_attributes = FactoryGirl.attributes_for(:post)
    post3 = FactoryGirl.build_stubbed(:post)
    posts1 = FactoryGirl.create_list(:post, 2)
    posts2 = FactoryGirl.build_list(:post, 2)
    posts3 = FactoryGirl.create_pair(:post)
    posts4 = FactoryGirl.build_pair(:post)
  end
      '}
      let(:test_rewritten_content) { '
  test "post" do
    post1 = create(:post)
    post2 = build(:post)
    post_attributes = attributes_for(:post)
    post3 = build_stubbed(:post)
    posts1 = create_list(:post, 2)
    posts2 = build_list(:post, 2)
    posts3 = create_pair(:post)
    posts4 = build_pair(:post)
  end
      '}

      include_examples 'convertable'
    end
  end
end
