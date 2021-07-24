# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Explicity spec type in rspec-rails' do
  let(:rewriter_name) { 'rspec/explicit_spec_type' }

  context 'unit test' do
    let(:fake_file_path) { 'spec/models/post_spec.rb' }
    let(:test_content) { <<~EOS }
      describe Post do
        describe '#save' do
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      describe Post, type: :model do
        describe '#save' do
        end
      end
    EOS

    include_examples 'convertable'
  end

  context 'unit test including type' do
    let(:fake_file_path) { 'spec/models/comment_spec.rb' }
    let(:test_content) { <<~EOS }
      RSpec.describe Comment, :type => :model do
        describe '#save' do
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      RSpec.describe Comment, :type => :model do
        describe '#save' do
        end
      end
    EOS

    include_examples 'convertable'
  end

  context 'functional test' do
    let(:fake_file_path) { 'spec/controllers/posts_controller_spec.rb' }
    let(:test_content) { <<~EOS }
      describe PostsController, type: :controller do
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      describe PostsController, type: :controller do
      end
    EOS

    include_examples 'convertable'
  end

  context 'functional test including type' do
    let(:fake_file_path) { 'spec/controllers/posts_controller_spec.rb' }
    let(:test_content) { <<~EOS }
      describe PostsController do
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      describe PostsController, type: :controller do
      end
    EOS

    include_examples 'convertable'
  end

  context 'helper test' do
    let(:fake_file_path) { 'spec/helpers/posts_helper_spec.rb' }
    let(:test_content) { <<~EOS }
      describe PostsHelper do
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      describe PostsHelper, type: :helper do
      end
    EOS

    include_examples 'convertable'
  end

  context 'mailer test' do
    let(:fake_file_path) { 'spec/mailers/post_mailer_spec.rb' }
    let(:test_content) { <<~EOS }
      describe PostMailer do
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      describe PostMailer, type: :mailer do
      end
    EOS

    include_examples 'convertable'
  end

  context 'spec/rails_helper' do
    let(:fake_file_path) { 'spec/rails_helper.rb' }
    let(:test_content) { <<~EOS }
      RSpec.configure do |rspec|
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      RSpec.configure do |rspec|
        rspec.infer_spec_type_from_file_location!
      end
    EOS

    include_examples 'convertable'
  end
end
