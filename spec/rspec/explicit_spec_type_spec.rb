require 'spec_helper'

RSpec.describe 'Explicity spec type in rspec-rails' do
  let!(:rewriter_path) { File.join(File.dirname(__FILE__), '../../lib/rspec/explicit_spec_type.rb') }
  let!(:rewriter) { eval(File.read(rewriter_path)) }

  describe 'with fakefs', fakefs: true do
    let(:post_model_spec_content) { "
describe Post do
  describe '#save' do
  end
end
    "}
    let(:post_model_spec_rewritten_content) { "
describe Post, type: :model do
  describe '#save' do
  end
end
    "}
    let(:comment_model_spec_content) { "
RSpec.describe Comment, :type => :model do
  describe '#save' do
  end
end
    "}
    let(:comment_model_spec_rewritten_content) { "
RSpec.describe Comment, :type => :model do
  describe '#save' do
  end
end
    "}
    let(:posts_controller_spec_content) { "
describe PostsController do
end
    "}
    let(:posts_controller_spec_rewritten_content) { "
describe PostsController, type: :controller do
end
    "}
    let(:posts_helper_spec_content) { "
describe PostsHelper do
end
    "}
    let(:posts_helper_spec_rewritten_content) { "
describe PostsHelper, type: :helper do
end
    "}
    let(:post_mailer_spec_content) { "
describe PostMailer do
end
    "}
    let(:post_mailer_spec_rewritten_content) { "
describe PostMailer, type: :mailer do
end
    "}
    let(:rails_spec_content) { "
RSpec.configure do |rspec|
end
    "}
    let(:rails_spec_rewritten_content) { "
RSpec.configure do |rspec|
  rspec.infer_spec_type_from_file_location!
end
    "}

    it 'converts' do
      FileUtils.mkdir_p 'spec/models'
      FileUtils.mkdir_p 'spec/controllers'
      FileUtils.mkdir_p 'spec/helpers'
      FileUtils.mkdir_p 'spec/mailers'
      File.write 'spec/rails_helper.rb', rails_spec_content
      File.write 'spec/models/post_spec.rb', post_model_spec_content
      File.write 'spec/models/comment_spec.rb', comment_model_spec_content
      File.write 'spec/controllers/posts_controller_spec.rb', posts_controller_spec_content
      File.write 'spec/helpers/posts_helper_spec.rb', posts_helper_spec_content
      File.write 'spec/mailers/post_mailer_spec.rb', post_mailer_spec_content
      rewriter.process
      expect(File.read 'spec/rails_helper.rb').to eq rails_spec_rewritten_content
      expect(File.read 'spec/models/post_spec.rb').to eq post_model_spec_rewritten_content
      expect(File.read 'spec/models/comment_spec.rb').to eq comment_model_spec_rewritten_content
      expect(File.read 'spec/controllers/posts_controller_spec.rb').to eq posts_controller_spec_rewritten_content
      expect(File.read 'spec/helpers/posts_helper_spec.rb').to eq posts_helper_spec_rewritten_content
      expect(File.read 'spec/mailers/post_mailer_spec.rb').to eq post_mailer_spec_rewritten_content
    end
  end
end
