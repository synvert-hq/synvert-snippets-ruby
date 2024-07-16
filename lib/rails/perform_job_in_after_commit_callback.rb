# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'perform_job_in_after_commit_callback' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It prefers performing a job in after_commit callback.

    ```ruby
    class User < ApplicationRecord
      after_create :send_notification

      def send_notification
        NotificationJob.perform_later(self)
      end
    end
    ```

    =>

    ```ruby
    class User < ApplicationRecord
      after_create_commit :send_notification

      def send_notification
        NotificationJob.perform_later(self)
      end
    end
    ```
  EOS

  call_helper 'ruby/parse'
  definitions = load_data :ruby_definitions
  job_classes = definitions.find_classes_by_superclass('ApplicationJob').map(&:full_name) +
                definitions.find_classes_by_superclass('Sidekiq::Job').map(&:full_name)
  mailer_classes = definitions.find_classes_by_superclass('ApplicationMailer').map(&:name)

  within_files Synvert::RAILS_MODEL_FILES do
    find_node '.class_node' do
      callback_names_with_actions = {}

      find_node node_type: 'call_node', receiver: nil, name: { in: %i[after_create after_update after_save] } do
        callback_names_with_actions[node.arguments.arguments.first.to_value.to_s] =
          NodeMutation::ReplaceAction.new(node, :name, with: '{{name}}_commit', adapter: mutation_adapter)
      end

      find_node node_type: 'def_node', name: { in: callback_names_with_actions.keys } do
        if_exist_node ".call_node[receiver=~/\\A(#{job_classes.join('|')})/][name IN (perform_later perform_async perform_in perform_at)]" do
          add_action(callback_names_with_actions[node.name.to_s])
        end
        if_exist_node ".call_node[receiver=~/\\A(#{mailer_classes.join('|')})/][name=deliver_later]" do
          add_action(callback_names_with_actions[node.name.to_s])
        end
      end
    end
  end
end
