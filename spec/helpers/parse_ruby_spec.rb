# frozen_string_literal: true

require 'spec_helper'
require 'helpers/parse_ruby'

RSpec.describe 'ruby/parse helper', fakefs: true do
  it 'gets definitions data' do
    rewriter =
      Synvert::Rewriter.new 'test', 'ruby_parse_helper' do
        call_helper 'ruby/parse'
      end

    FileUtils.mkdir_p('app/models/synvert')
    File.write('app/models/synvert/user.rb', <<~EOF)
      module Synvert
        class User
          include Trackable
          prepend Authenticatable
          extend ClassMethods

          ROLES = %w[user admin].freeze

          class << self
            def system
            end

            def bot
            end
          end

          def self.authenticate?(email, password)
            user = find_by(email:)
            user.valid_password?(password)
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

    definitions = rewriter.process

    expect(definitions.to_h).to eq(
      {
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
                methods: [{ name: "user_type", local_calls: [] }],
                static_methods: [],
                constants: [],
                include_modules: [],
                prepend_modules: [],
                extend_modules: [],
                singleton: nil,
                ancestors: ["Synvert::User", "Authenticatable", "Trackable"]
              },
              {
                name: "User",
                superclass: nil,
                singleton: {
                  constants: [],
                  methods: [
                    { name: 'system', local_calls: [] },
                    { name: 'bot', local_calls: [] }
                  ],
                  ancestors: []
                },
                classes: [],
                modules: [],
                methods: [{ name: "user_type", local_calls: [] }],
                static_methods: [
                  {
                    name: 'authenticate?',
                    local_calls: ['find_by']
                  }
                ],
                constants: [{ name: "ROLES" }],
                include_modules: ["Trackable"],
                prepend_modules: ["Authenticatable"],
                extend_modules: ["ClassMethods"],
                ancestors: ["Authenticatable", "Trackable"]
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
      }
    )
  end

  it 'finds class by full_name' do
    rewriter =
      Synvert::Rewriter.new 'test', 'ruby_parse_helper' do
        call_helper 'ruby/parse'
      end

    FileUtils.mkdir_p('app/jobs/synvert')
    File.write('app/jobs/synvert/user_job.rb', <<~EOF)
      module Synvert
        class UserJob < SynvertJob
        end
      end
    EOF

    definitions = rewriter.process

    class_definition = definitions.find_class_by_full_name('Synvert::UserJob')
    expect(class_definition.name).to eq('UserJob')
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

    definitions = rewriter.process

    classes = definitions.find_classes_by_ancestor('ApplicationJob')
    expect(classes.map(&:full_name)).to eq(['SynvertJob', 'Synvert::UserJob'])
  end

  it 'finds method by name' do
    rewriter =
      Synvert::Rewriter.new 'test', 'ruby_parse_helper' do
        call_helper 'ruby/parse'
      end

    FileUtils.mkdir_p('app/models')
    File.write('app/models/user.rb', <<~EOF)
      class User < ApplicationRecord
        def activate
        end

        def deactivate
        end
      end
    EOF

    definitions = rewriter.process

    class_definition = definitions.find_class_by_full_name('User')
    expect(class_definition.find_method_by_name('deactivate').name).to eq('deactivate')
  end

  it 'check if call method' do
    rewriter =
      Synvert::Rewriter.new 'test', 'ruby_parse_helper' do
        call_helper 'ruby/parse'
      end

    FileUtils.mkdir_p('app/models')
    File.write('app/models/user.rb', <<~EOF)
      class User < ApplicationRecord
        def activate
          update(:active: true)
          send_notification
        end

        def deactivate
          update(:active: false)
          send_notification
        end

        def send_notificaiton
        end
      end
    EOF

    definitions = rewriter.process

    class_definition = definitions.find_class_by_full_name('User')
    method_definition = class_definition.find_method_by_name('deactivate')
    expect(method_definition.call_method?('send_notification')).to be_truthy
    expect(method_definition.call_method?('activate')).to be_falsey
  end

  it 'check if call any method' do
    rewriter =
      Synvert::Rewriter.new 'test', 'ruby_parse_helper' do
        call_helper 'ruby/parse'
      end

    FileUtils.mkdir_p('app/models')
    File.write('app/models/user.rb', <<~EOF)
      class User < ApplicationRecord
        def activate
          update(:active: true)
          send_notification
        end

        def deactivate
          update(:active: false)
          send_notification
        end

        def send_notificaiton
        end
      end
    EOF

    definitions = rewriter.process

    class_definition = definitions.find_class_by_full_name('User')
    method_definition = class_definition.find_method_by_name('deactivate')
    expect(method_definition.call_any_method?(['send_notification', 'activate'])).to be_truthy
  end
end
