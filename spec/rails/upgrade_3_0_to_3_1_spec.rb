require 'spec_helper'

RSpec.describe 'Upgrade rails from 3.0 to 3.1' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/upgrade_3_0_to_3_1.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:application_content) { "
Synvert::Application.configure do
end
    "}
    let(:application_rewritten_content) { "
Synvert::Application.configure do
  config.assets.version = '1.0'
  config.assets.enabled = true
end
    "}
    let(:development_content) { "
Synvert::Application.configure do
  config.action_view.debug_rjs = true
end
    "}
    let(:development_rewritten_content) { "
Synvert::Application.configure do
  config.assets.compress = false
  config.assets.debug = true
end
    "}
    let(:production_content) { "
Synvert::Application.configure do
end
    "}
    let(:production_rewritten_content) { "
Synvert::Application.configure do
  config.assets.digest = true
  config.assets.compile = false
  config.assets.compress = true
end
    "}
    let(:test_content) { "
Synvert::Application.configure do
end
    "}
    let(:test_rewritten_content) { '
Synvert::Application.configure do
  config.static_cache_control = "public, max-age=3600"
  config.serve_static_assets = true
end
    '}
    let(:wrap_parameters_rewritten_content) { "
# Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# Disable root element in JSON by default.
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
    ".strip}
    let(:session_store_content) { "
Synvert::Application.config.session_store :cookie_store, key: 'somethingold'
    "}
    let(:session_store_rewritten_content) { "
Synvert::Application.config.session_store :cookie_store, key: '_synvert-session'
    "}
    let(:create_posts_content) { "
class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :name
    end
    add_index :posts, :name
  end
  def self.down
    drop_table :posts
  end
end
    "}
    let(:create_posts_rewritten_content) { "
class CreatePosts < ActiveRecord::Migration
  def up
    create_table :posts do |t|
      t.string :name
    end
    add_index :posts, :name
  end
  def down
    drop_table :posts
  end
end
    "}

    it 'converts' do
      FileUtils.mkdir_p 'config/environments'
      FileUtils.mkdir_p 'config/initializers'
      FileUtils.mkdir_p 'db/migrate'
      File.write 'config/application.rb', application_content
      File.write 'config/environments/development.rb', development_content
      File.write 'config/environments/production.rb', production_content
      File.write 'config/environments/test.rb', test_content
      File.write 'config/initializers/session_store.rb', session_store_content
      File.write 'db/migrate/20140831000000_create_posts.rb', create_posts_content
      @rewriter.process
      expect(File.read 'config/application.rb').to eq application_rewritten_content
      expect(File.read 'config/environments/production.rb').to eq production_rewritten_content
      expect(File.read 'config/environments/test.rb').to eq test_rewritten_content
      expect(File.read 'config/initializers/wrap_parameters.rb').to eq wrap_parameters_rewritten_content
      expect(File.read 'config/initializers/session_store.rb').to eq session_store_rewritten_content
      expect(File.read 'db/migrate/20140831000000_create_posts.rb').to eq create_posts_rewritten_content
    end
  end
end
