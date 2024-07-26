# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rails enqueue job in after_commit callback' do
  before { load_helpers(%w[helpers/parse_ruby]) }

  let(:rewriter_name) { 'rails/enqueue_job_in_after_commit_callback' }

  context 'ApplicationJob' do
    let(:fake_file_paths) { ['app/jobs/notification_job.rb', 'app/models/user.rb'] }
    let(:test_contents) { [<<~EOF.strip, <<~EOF.strip] }
      class NotificationJob < ApplicationJob
      end
    EOF
      class User < ApplicationRecord
        after_create :send_notification
        after_save :update_cache

        def send_notification
          NotificationJob.perform_later(self)
        end

        def update_cache
          Cache.update(self)
        end
      end
    EOF
    let(:test_rewritten_contents) { [<<~EOF.strip, <<~EOF.strip] }
      class NotificationJob < ApplicationJob
      end
    EOF
      class User < ApplicationRecord
        after_create_commit :send_notification
        after_save :update_cache

        def send_notification
          NotificationJob.perform_later(self)
        end

        def update_cache
          Cache.update(self)
        end
      end
    EOF

    include_examples 'convertable with multiple files'
  end

  context 'Sidekiq' do
    let(:fake_file_paths) { ['app/jobs/notification_job.rb', 'app/models/user.rb'] }
    let(:test_contents) { [<<~EOF.strip, <<~EOF.strip] }
      class NotificationJob
        include Sidekiq::Job

        def perform(user)
        end
      end
    EOF
      class User < ApplicationRecord
        after_create :send_notification
        after_save :update_cache

        def send_notification
          notify_user
        end

        def update_cache
          Cache.update(self)
        end

        def notify_user
          NotificationJob.perform_async(self)
        end
      end
    EOF
    let(:test_rewritten_contents) { [<<~EOF.strip, <<~EOF.strip] }
      class NotificationJob
        include Sidekiq::Job

        def perform(user)
        end
      end
    EOF
      class User < ApplicationRecord
        after_create_commit :send_notification
        after_save :update_cache

        def send_notification
          notify_user
        end

        def update_cache
          Cache.update(self)
        end

        def notify_user
          NotificationJob.perform_async(self)
        end
      end
    EOF

    include_examples 'convertable with multiple files'
  end

  context 'Mailer deliver_later' do
    let(:fake_file_paths) { ['app/mailers/user_mailer.rb', 'app/models/user.rb'] }
    let(:test_contents) { [<<~EOF.strip, <<~EOF.strip] }
      class UserMailer < ApplicationMailer
      end
    EOF
      class User < ApplicationRecord
        after_create :send_notification
        after_save :update_cache

        def send_notification
          UserMailer.welcome(self).deliver_later
        end

        def update_cache
          Cache.update(self)
        end
      end
    EOF
    let(:test_rewritten_contents) { [<<~EOF.strip, <<~EOF.strip] }
      class UserMailer < ApplicationMailer
      end
    EOF
      class User < ApplicationRecord
        after_create_commit :send_notification
        after_save :update_cache

        def send_notification
          UserMailer.welcome(self).deliver_later
        end

        def update_cache
          Cache.update(self)
        end
      end
    EOF

    include_examples 'convertable with multiple files'
  end
end
