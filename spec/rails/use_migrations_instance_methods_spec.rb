# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Uses instance methods in migrations' do
  let(:rewriter_name) { 'rails/use_migrations_instance_methods' }
  let(:fake_file_path) { 'db/migrate/20140831000000_create_posts.rb' }
  let(:test_content) {
    '
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
  '
  }
  let(:test_rewritten_content) {
    '
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
  '
  }

  include_examples 'convertable'
end
