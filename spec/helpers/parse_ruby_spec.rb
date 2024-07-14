# frozen_string_literal: true

require 'spec_helper'
require 'helpers/parse_ruby'

RSpec.describe 'ruby/parse helper', fakefs: true do
  it 'saves/loads definitions data' do
    rewriter =
      Synvert::Rewriter.new 'test', 'ruby_parse_helper' do
        call_helper 'ruby/parse'
      end

    FileUtils.mkdir_p('app/models/synvert')
    File.write('app/models/synvert/user.rb', <<~EOF)
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
    File.write('app/models/synvert/admin.rb', <<~EOF)
      module Synvert
        class Admin < User
          def user_type
            "admin"
          end
        end
      end
    EOF

    rewriter.process

    definitions = rewriter.load_data(:ruby_definitions)
    expect(definitions.to_h).to eq({
      classes: [],
      modules: [
        {
          name: "Synvert",
          classes: [
            {
              name: "Admin",
              superclass: "User",
              classes: [],
              modules: [],
              methods: [{ name: "user_type" }],
              static_methods: [],
              constants: [],
              included_modules: [],
              singleton: nil,
              ancestors: ["Synvert::User", "Trackable"]
            },
            {
              name: "User",
              superclass: nil,
              singleton: {
                constants: [],
                methods: [
                  { name: 'system' },
                  { name: 'bot' }
                ],
                ancestors: []
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
          constants: [],
          singleton: nil,
          ancestors: []
        }
      ],
      constants: [],
      methods: []
    })
  end

  it 'finds classes by superclass' do
    rewriter =
      Synvert::Rewriter.new 'test', 'ruby_parse_helper' do
        call_helper 'ruby/parse'
      end

    FileUtils.mkdir_p('app/jobs/synvert')
    File.write('app/jobs/application.rb', <<~EOF)
      class ApplicationJob < ActiveJob::Base
      end
    EOF
    File.write('app/jobs/synvert_job.rb', <<~EOF)
      class SynvertJob < ApplicationJob
      end
    EOF
    File.write('app/jobs/synvert/user_job.rb', <<~EOF)
      module Synvert
        class UserJob < SynvertJob
        end
      end
    EOF

    rewriter.process

    definitions = rewriter.load_data(:ruby_definitions)
    classes = definitions.find_classes_by_superclass('ApplicationJob')
    expect(classes.map(&:full_name)).to eq(['SynvertJob', 'Synvert::UserJob'])
  end
end
