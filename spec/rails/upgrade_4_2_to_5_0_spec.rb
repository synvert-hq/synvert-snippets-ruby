# encoding: utf-8

require 'spec_helper'

RSpec.describe 'Upgrade rails from 4.2 to 5.0' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/upgrade_4_2_to_5_0.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  def indent_content(content, count: 2)
    content.strip.split("\n").map { |line| line.empty? ? line : "#{' ' * count}#{line}" }.join("\n")
  end

  describe 'with fakefs', fakefs: true do
    let(:production_content) {'
module Synvert
  class Application < Rails::Application
    config.static_cache_control = "public, max-age=31536000"
    config.serve_static_files = true
    config.middleware.use "Foo::Bar", foo: "bar"
  end
end
    '}
    let(:production_rewritten_content) {'
module Synvert
  class Application < Rails::Application
    config.public_file_server.headers = "public, max-age=31536000"
    config.public_file_server.enabled = true
    config.middleware.use Foo::Bar, foo: "bar"
  end
end
    '}
    let(:posts_controller_content) {'
class PostsController < ApplicationController
  rescue_from BadGateway do
    head status: 502
  end
  def test
    render nothing: true
  end
  def redirect
    head location: "/foo"
  end
  def redirect_back
    redirect_to :back
  end
end
    '}
    let(:posts_controller_rewritten_content) {'
class PostsController < ApplicationController
  rescue_from BadGateway do
    head 502
  end
  def test
    head :ok
  end
  def redirect
    head :ok, location: "/foo"
  end
  def redirect_back
    redirect_back
  end
end
    '}
    let(:nested_controller_content) {"
module Namespace
#{indent_content(posts_controller_content)}
end
    "}
    let(:nested_controller_rewritten_content) {"
module Namespace
#{indent_content(posts_controller_rewritten_content)}
end
    "}
    let(:post_model_content) {'
class Post < ActiveRecord::Base
  after_commit :add_to_index_later, on: :create
  after_commit :update_in_index_later, on: :update
  after_commit :remove_from_index_later, on: :destroy

  def test_load_error
  rescue MissingSourceFile
  end
end
    '}
    let(:application_record_rewritten_content) {'
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
    '.strip}
    let(:post_model_rewritten_content) {'
class Post < ApplicationRecord
  after_create_commit :add_to_index_later
  after_update_commit :update_in_index_later
  after_destroy_commit :remove_from_index_later

  def test_load_error
  rescue LoadError
  end
end
    '}
    let(:nested_model_content) {"
module Namespace
#{indent_content(post_model_content)}
end
    "}
    let(:nested_model_rewritten_content) {"
module Namespace
#{indent_content(post_model_rewritten_content)}
end
    "}

    let(:post_job_content) {'
class PostJob < ActiveJob::Base
end
    '}
    let(:application_job_rewritten_content) {'
class ApplicationJob < ActiveJob::Base

end
    '.strip}
    let(:post_job_rewritten_content) {'
class PostJob < ApplicationJob
end
    '}
    let(:nested_job_content) {"
module Namespace
#{indent_content(post_job_content)}
end
    "}
    let(:nested_job_rewritten_content) {"
module Namespace
#{indent_content(post_job_rewritten_content)}
end
    "}

    it 'converts', aggregate_failures: true do
      FileUtils.mkdir_p 'config/environments'
      FileUtils.mkdir_p 'app/controllers'
      FileUtils.mkdir_p 'app/controllers/namespace'
      FileUtils.mkdir_p 'app/models'
      FileUtils.mkdir_p 'app/models/namespace'
      FileUtils.mkdir_p 'app/jobs'
      FileUtils.mkdir_p 'app/jobs/namespace'
      File.write 'config/environments/production.rb', production_content
      File.write 'app/controllers/posts_controller.rb', posts_controller_content
      File.write 'app/controllers/namespace/posts_controller.rb', nested_controller_content
      File.write 'app/models/post.rb', post_model_content
      File.write 'app/models/namespace/post.rb', nested_model_content
      File.write 'app/jobs/post_job.rb', post_job_content
      File.write 'app/jobs/namespace/post_job.rb', nested_job_content
      @rewriter.process
      expect(File.read 'config/environments/production.rb').to eq production_rewritten_content
      expect(File.read 'app/controllers/posts_controller.rb').to eq posts_controller_rewritten_content
      expect(File.read 'app/controllers/namespace/posts_controller.rb').to eq nested_controller_rewritten_content
      expect(File.read 'app/models/application_record.rb').to eq application_record_rewritten_content
      expect(File.read 'app/models/post.rb').to eq post_model_rewritten_content
      expect(File.read 'app/models/namespace/post.rb').to eq nested_model_rewritten_content
      expect(File.read 'app/jobs/application_job.rb').to eq application_job_rewritten_content
      expect(File.read 'app/jobs/post_job.rb').to eq post_job_rewritten_content
      expect(File.read 'app/jobs/namespace/post_job.rb').to eq nested_job_rewritten_content
    end
  end
end
