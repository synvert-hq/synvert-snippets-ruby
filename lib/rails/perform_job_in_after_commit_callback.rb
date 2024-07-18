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

  definitions = call_helper 'ruby/parse'
  job_classes = definitions.find_classes_by_ancestor('ApplicationJob').map(&:full_name) +
                definitions.find_classes_by_ancestor('Sidekiq::Job').map(&:full_name)
  mailer_classes = definitions.find_classes_by_ancestor('ApplicationMailer').map(&:name)

  within_files Synvert::RAILS_MODEL_FILES do
    find_node '.class_node' do
      callback_names_with_actions = {}
      job_performed_def_names = []

      find_node node_type: 'call_node', receiver: nil, name: { in: %i[after_create after_update after_save] } do
        callback_names_with_actions[node.arguments.arguments.first.to_value.to_s] =
          NodeMutation::ReplaceAction.new(node, :name, with: '{{name}}_commit', adapter: mutation_adapter)
      end

      find_node node_type: 'def_node' do
        if_exist_node ".call_node[receiver=~/\\A(#{job_classes.join('|')})/][name IN (perform_later perform_async perform_in perform_at)]" do
          job_performed_def_names << node.name.to_s
        end
        if_exist_node ".call_node[receiver=~/\\A(#{mailer_classes.join('|')})/][name=deliver_later]" do
          job_performed_def_names << node.name.to_s
        end
      end

      class_definition = definitions.find_class_by_full_name(node.full_name)
      callback_names_with_actions.each do |callback_name, action|
        if job_performed_def_names.include?(callback_name)
          add_action(action)
          next
        end

        method_definition = class_definition.find_method_by_name(callback_name)
        if method_definition && method_definition.call_any_method?(job_performed_def_names)
          add_action(action)
        end
      end
    end
  end
end
