require 'spec_helper'

RSpec.describe 'Explicity spec type in rspec-rails' do
  let(:rewriter_name) { 'rspec/explicit_spec_type' }

  context 'unit test' do
    let(:fake_file_path) { 'spec/models/post_spec.rb' }
    let(:test_content) { "
describe Post do
  describe '#save' do
  end
end
    "}
    let(:test_rewritten_content) { "
describe Post, type: :model do
  describe '#save' do
  end
end
    "}

    include_examples 'convertable'
  end

  context 'unit test included type' do
    let(:fake_file_path) { 'spec/models/comment_spec.rb' }
    let(:test_content) { "
RSpec.describe Comment, :type => :model do
  describe '#save' do
  end
end
    "}
    let(:test_rewritten_content) { "
RSpec.describe Comment, :type => :model do
  describe '#save' do
  end
end
    "}

    include_examples 'convertable'
  end

  context 'functional test' do
    let(:fake_file_path) { 'spec/controllers/posts_controller_spec.rb' }
    let(:test_content) { "
describe PostsController do
end
    "}
    let(:test_rewritten_content) { "
describe PostsController, type: :controller do
end
    "}

    include_examples 'convertable'
  end

  context 'helper test' do
    let(:fake_file_path) { 'spec/helpers/posts_helper_spec.rb' }
    let(:test_content) { "
describe PostsHelper do
end
    "}
    let(:test_rewritten_content) { "
describe PostsHelper, type: :helper do
end
    "}

    include_examples 'convertable'
  end

  context 'mailer test' do
    let(:fake_file_path) { 'spec/mailers/post_mailer_spec.rb' }
    let(:test_content) { "
describe PostMailer do
end
    "}
    let(:test_rewritten_content) { "
describe PostMailer, type: :mailer do
end
    "}

    include_examples 'convertable'
  end

  context 'spec/rails_helper' do
    let(:fake_file_path) { 'spec/rails_helper.rb' }
    let(:test_content) { "
RSpec.configure do |rspec|
end
    "}
    let(:test_rewritten_content) { "
RSpec.configure do |rspec|
  rspec.infer_spec_type_from_file_location!
end
    "}

    include_examples 'convertable'
  end
end
