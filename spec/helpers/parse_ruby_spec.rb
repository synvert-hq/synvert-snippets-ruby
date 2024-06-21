# frozen_string_literal: true

require 'spec_helper'
require 'helpers/parse_ruby'

RSpec.describe 'ruby/parse helper', fakefs: true do
  it 'saves definitions data' do
    rewriter =
      Synvert::Rewriter.new 'test', 'ruby_parse_helper' do
        call_helper 'ruby/parse'
      end

    FileUtils.mkdir_p('app/models')
    File.write('app/models/user.rb', <<~EOF)
      module Synvert
        class User
          include Trackable

          ROLES = %w[user admin].freeze

          class << self
            def system
            end

            def bot
            end
          end

          def self.authenticate?(email, password)
          end

          def user_type
            "user"
          end
        end
      end
    EOF
    File.write('app/models/admin.rb', <<~EOF)
      module Synvert
        class Admin < User
          def user_type
            "admin"
          end
        end
      end
    EOF

    rewriter.process

    expect(rewriter.load_data(:ruby_definitions)).to eq(
      {
        classes: [],
        modules: [
          {
            name: "Synvert",
            classes: [
              {
                name: "Admin",
                superclass: "User",
                singleton: {},
                classes: [],
                modules: [],
                methods: [{ name: "user_type" }],
                static_methods: [],
                constants: [],
                included_modules: [],
                ancestors: ["User", "Trackable"]
              },
              {
                name: "User",
                superclass: nil,
                singleton: {
                  methods: [
                    { name: 'system' },
                    { name: 'bot' }
                  ]
                },
                classes: [],
                modules: [],
                methods: [{ name: "user_type" }],
                static_methods: [{ name: 'authenticate?' }],
                constants: [{ name: "ROLES" }],
                included_modules: ["Trackable"],
                ancestors: ["Trackable"]
              }
            ],
            modules: [],
            methods: [],
            static_methods: [],
            constants: []
          }
        ]
      }
    )
  end
end
