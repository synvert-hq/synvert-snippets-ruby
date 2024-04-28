# frozen_string_literal: true

require 'spec_helper'
require 'helpers/parse_rails'

RSpec.describe 'rails/parse helper', fakefs: true do
  it 'saves tables data' do
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

    rewriter.process

    expect(rewriter.load_data(:rails_tables)).to eq({
      "users" => {
        columns: [
          { name: "name", type: "string" },
          { name: "email", type: "string" },
          { name: "created_at", type: "datetime" },
          { name: "updated_at", type: "datetime" }
        ],
        indices: [
          { columns: ["email"], name: "index_users_on_email" }
        ]
      }
    })
  end
end
