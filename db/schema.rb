# frozen_string_literal: true

  ActiveRecord::Schema.define(version: 20140211112752) do
    create_table "users", force: true do |t|
      t.string   "login"
      t.string   "email"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "role",                      default: 0,     null: false
      t.boolean  "admin",                     default: false, null: false
      t.index    [:email, :role]
    end
  end
    