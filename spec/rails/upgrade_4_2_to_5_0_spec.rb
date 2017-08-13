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
    let(:application_content) { '
module Synvert
  class Application < Rails::Application
    config.raise_in_transactional_callbacks = true
  end
end
    '}
    let(:application_rewritten_content) { '
module Synvert
  class Application < Rails::Application
  end
end
    '}
    let(:production_content) { '
module Synvert
  class Application < Rails::Application
    config.static_cache_control = "public, max-age=31536000"
    config.serve_static_files = true
    config.middleware.use "Foo::Bar", foo: "bar"
  end
end
    '}
    let(:production_rewritten_content) { '
module Synvert
  class Application < Rails::Application
    config.public_file_server.headers = { "Cache-Control" => "public, max-age=31536000" }
    config.public_file_server.enabled = true
    config.middleware.use Foo::Bar, foo: "bar"
  end
end
    '}
    let(:posts_controller_content) { '
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
    let(:posts_controller_rewritten_content) { '
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
    let(:nested_controller_content) { "
module Namespace
#{indent_content(posts_controller_content)}
end
    "}
    let(:nested_controller_rewritten_content) { "
module Namespace
#{indent_content(posts_controller_rewritten_content)}
end
    "}
    let(:post_model_content) { '
class Post < ActiveRecord::Base
  after_commit :add_to_index_later, on: :create, if: :can_add?
  after_commit :update_in_index_later, on: :update
  after_commit :remove_from_index_later, on: :destroy

  def test_load_error
    rescue MissingSourceFile
  end

  def validate_author
    errors[:base] = "author not present" unless author
    self.errors[:base] = "author not present" unless author
  end
end
    '}
    let(:application_record_rewritten_content) { '
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
    '.strip}
    let(:post_model_rewritten_content) { '
class Post < ApplicationRecord
  after_create_commit :add_to_index_later, if: :can_add?
  after_update_commit :update_in_index_later
  after_destroy_commit :remove_from_index_later

  def test_load_error
    rescue LoadError
  end

  def validate_author
    errors.add(:base, "author not present") unless author
    self.errors.add(:base, "author not present") unless author
  end
end
    '}
    let(:nested_model_content) { "
module Namespace
#{indent_content(post_model_content)}
end
    "}
    let(:nested_model_rewritten_content) { "
module Namespace
#{indent_content(post_model_rewritten_content)}
end
    "}

    let(:post_job_content) { '
class PostJob < ActiveJob::Base
end
    '}
    let(:application_job_rewritten_content) { '
class ApplicationJob < ActiveJob::Base

end
    '.strip}
    let(:post_job_rewritten_content) { '
class PostJob < ApplicationJob
end
    '}
    let(:nested_job_content) { "
module Namespace
#{indent_content(post_job_content)}
end
    "}
    let(:nested_job_rewritten_content) { "
module Namespace
#{indent_content(post_job_rewritten_content)}
end
    "}
    let(:new_framework_defaults_rewritten_content) { '
# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 5.0 upgrade.
#
# Read the Guide for Upgrading Ruby on Rails for more info on each option.

# Enable per-form CSRF tokens. Previous versions had false.
Rails.application.config.action_controller.per_form_csrf_tokens = true

# Enable origin-checking CSRF mitigation. Previous versions had false.
Rails.application.config.action_controller.forgery_protection_origin_check = true

# Make Ruby 2.4 preserve the timezone of the receiver when calling `to_time`.
# Previous versions had false.
ActiveSupport.to_time_preserves_timezone = true

# Require `belongs_to` associations by default. Previous versions had false.
Rails.application.config.active_record.belongs_to_required_by_default = true

# Do not halt callback chains when a callback returns false. Previous versions had true.
ActiveSupport.halt_callback_chains_on_return_false = false

# Configure SSL options to enable HSTS with subdomains. Previous versions had false.
Rails.application.config.ssl_options = { hsts: { subdomains: true } }
    '.strip}
    let(:posts_controller_test_content) { '
class PostsControllerTest < ActionController::TestCase
  def test_show
    get :show, { id: user.id }, { notice: "Welcome" }, { admin: user.admin? }
  end

  def test_index
    get :index, params: { query: "test" }
  end

  def test_create
    post :create, name: "user"
  end

  def test_destroy
    delete :destroy, { id: user.id }, nil, { admin: user.admin? }
  end
end
    '.strip}
    let(:posts_controller_test_rewritten_content) { '
class PostsControllerTest < ActionController::TestCase
  def test_show
    get :show, params: { id: user.id }, flash: { notice: "Welcome" }, session: { admin: user.admin? }
  end

  def test_index
    get :index, params: { query: "test" }
  end

  def test_create
    post :create, params: { name: "user" }
  end

  def test_destroy
    delete :destroy, params: { id: user.id }, session: { admin: user.admin? }
  end
end
    '.strip}

    it 'converts', aggregate_failures: true do
      FileUtils.mkdir_p 'config/environments'
      FileUtils.mkdir_p 'config/initializers'
      FileUtils.mkdir_p 'app/controllers'
      FileUtils.mkdir_p 'app/controllers/namespace'
      FileUtils.mkdir_p 'app/models'
      FileUtils.mkdir_p 'app/models/namespace'
      FileUtils.mkdir_p 'app/jobs'
      FileUtils.mkdir_p 'app/jobs/namespace'
      FileUtils.mkdir_p 'test/functional'
      File.write 'config/application.rb', application_content
      File.write 'config/environments/production.rb', production_content
      File.write 'app/controllers/posts_controller.rb', posts_controller_content
      File.write 'app/controllers/namespace/posts_controller.rb', nested_controller_content
      File.write 'app/models/post.rb', post_model_content
      File.write 'app/models/namespace/post.rb', nested_model_content
      File.write 'app/jobs/post_job.rb', post_job_content
      File.write 'app/jobs/namespace/post_job.rb', nested_job_content
      File.write 'test/functional/posts_controller_test.rb', posts_controller_test_content
      @rewriter.process
      expect(File.read 'config/application.rb').to eq application_rewritten_content
      expect(File.read 'config/environments/production.rb').to eq production_rewritten_content
      expect(File.read 'config/initializers/new_framework_defaults.rb').to eq new_framework_defaults_rewritten_content
      expect(File.read 'app/controllers/posts_controller.rb').to eq posts_controller_rewritten_content
      expect(File.read 'app/controllers/namespace/posts_controller.rb').to eq nested_controller_rewritten_content
      expect(File.read 'app/models/application_record.rb').to eq application_record_rewritten_content
      expect(File.read 'app/models/post.rb').to eq post_model_rewritten_content
      expect(File.read 'app/models/namespace/post.rb').to eq nested_model_rewritten_content
      expect(File.read 'app/jobs/application_job.rb').to eq application_job_rewritten_content
      expect(File.read 'app/jobs/post_job.rb').to eq post_job_rewritten_content
      expect(File.read 'app/jobs/namespace/post_job.rb').to eq nested_job_rewritten_content
      expect(File.read 'test/functional/posts_controller_test.rb').to eq posts_controller_test_rewritten_content
    end
  end
end
