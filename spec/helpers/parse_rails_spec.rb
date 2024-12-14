# frozen_string_literal: true

require 'spec_helper'
require 'helpers/parse_rails'

RSpec.describe 'rails/parse helper', fakefs: true do
  it 'gets table definitions' do
    rewriter =
      Synvert::Rewriter.new 'test', 'rails_parse_helper' do
        call_helper 'rails/parse'
      end

    file_path = 'db/schema.rb'
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, <<~EOF)
      ActiveRecord::Schema[7.1].define(version: 2024_04_22_081242) do
        # These are extensions that must be enabled in order to support this database
        enable_extension "plpgsql"

        create_table "users", force: :cascade do |t|
          t.string "name", null: false
          t.string "email", null: false
          t.datetime "created_at", null: false
          t.datetime "updated_at", null: false
          t.index ["email"], name: "index_users_on_email", unique: true
        end
      end
    EOF

    definitions = rewriter.process

    expect(definitions.table_definitions.to_h).to eq(
      [
        {
          name: "users",
          columns: [
            { name: "name", type: "string" },
            { name: "email", type: "string" },
            { name: "created_at", type: "datetime" },
            { name: "updated_at", type: "datetime" }
          ],
          indices: [
            { name: "index_users_on_email", columns: ["email"] }
          ]
        }
      ]
    )
  end

  it 'gets model definitions' do
    rewriter =
      Synvert::Rewriter.new 'test', 'rails_parse_helper' do
        call_helper 'rails/parse'
      end

    FileUtils.mkdir_p('app/models')
    File.write('app/models/user.rb', <<~EOF)
      class User < ApplicationRecord
        belongs_to :organization
        has_many :posts, dependent: :destroy
      end
    EOF
    File.write('app/models/picture.rb', <<~EOF)
      class Picture < ApplicationRecord
        belongs_to :imageable, polymorphic: true
      end
    EOF

    definitions = rewriter.process

    expect(definitions.model_definitions.to_h).to eq(
      [
        {
          name: 'Picture',
          associations: [
            {
              name: 'imageable',
              type: 'belongs_to',
              options: { polymorphic: true }
            },
          ]
        },
        {
          name: 'User',
          associations: [
            {
              name: 'organization',
              type: 'belongs_to',
              options: {}
            },
            { name: 'posts', type: 'has_many', options: {} }
          ]
        }
      ]
    )
  end
end
