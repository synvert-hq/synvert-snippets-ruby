Synvert::Rewriter.new 'rails', 'convert_mailers_2_3_to_3_0' do
  description <<-EOF
It converts rails mailers from 2.3 to 3.0.

  class Notifier < ActionMailer::Base
    def signup_notification(recipient)
      recipients      recipient.email_address_with_name
      subject         "New account information"
      from            "system@example.com"
      content_type    "multipart/alternative"
      body            :account => recipient
    end
  end
  =>
  class Notifier < ActionMailer::Base
    def signup_notification(recipient)
      @account = recipient
      mail(:to => recipient.email_address_with_name, :subject => "New account information", :from => "system@example.com")
    end
  end

  Notifier.deliver_signup_notification(recipient)
  =>
  Notifier.signup_notification(recipient).deliver

  message = Notifier.create_signup_notification(recipient)
  Notifier.deliver(message)
  =>
  message = Notifier.signup_notification(recipient)
  message.deliver
  EOF

  if_gem 'rails', {gte: '2.3.0'}

  mailer_methods = {}

  %w(app/models/**/*.rb app/mailers/**/*.rb).each do |file_pattern|
    within_files file_pattern do
      # class Notifier < ActionMailer::Base
      #   def signup_notification(recipient)
      #     recipients      recipient.email_address_with_name
      #     subject         "New account information"
      #     from            "system@example.com"
      #     content_type    "multipart/alternative"
      #     body            :account => recipient
      #   end
      # end
      # =>
      # class Notifier < ActionMailer::Base
      #   def signup_notification(recipient)
      #     @account = recipient
      #     mail(:to => recipient.email_address_with_name, :subject => "New account information", :from => "system@example.com")
      #   end
      # end
      within_node type: 'class', parent_class: 'ActionMailer::Base' do
        class_name = node.name
        within_node type: 'def' do
          args = {}
          with_node type: 'send', message: 'recipients' do
            args[:to] = node.arguments.first.to_source
            remove
          end
          %w(subject from cc bcc).each do |message|
            with_node type: 'send', message: message do
              args[message.to_sym] = node.arguments.first.to_source
              remove
            end
          end
          with_node type: 'send', message: 'content_type' do
            remove
          end
          with_node type: 'send', message: 'body' do
            body_argument = node.arguments.first
            if :hash == body_argument.type
              replace_with body_argument.children.map { |pair_node| "@#{pair_node.key.to_value} = #{pair_node.value.to_source}" }.join("\n")
            end
          end
          if args.size > 0
            mailer_methods[class_name] ||= []
            mailer_methods[class_name] << node.name
            args_str = args.map { |key, value| ":#{key} => #{value}" }.join(', ')
            append "  mail(#{args_str})"
          end
        end
      end
    end
  end

  %w(app/**/*.rb lib/**/*.rb).each do |file_pattern|
    within_files file_pattern do
      # Notifier.deliver_signup_notification(recipient)
      # =>
      # Notifier.signup_notification(recipient).deliver
      with_node type: 'send', message: /^deliver_/ do
        mailer_method = node.message.to_s.sub(/^deliver_/, '').to_sym
        if mailer_methods[node.receiver] && mailer_methods[node.receiver].include?(mailer_method)
          replace_with "{{receiver}}.#{mailer_method}({{arguments}}).deliver"
        end
      end

      # message = Notifier.create_signup_notification(recipient)
      # =>
      # message = Notifier.signup_notification(recipient)
      with_node type: 'send', message: /^create_/ do
        mailer_method = node.message.to_s.sub(/^create_/, '').to_sym
        if mailer_methods[node.receiver] && mailer_methods[node.receiver].include?(mailer_method)
          replace_with "{{receiver}}.#{mailer_method}({{arguments}})"
        end
      end

      # Notifier.deliver(message)
      # =>
      # message.deliver
      with_node type: 'send', message: 'deliver' do
        if mailer_methods[node.receiver]
          replace_with "{{arguments}}.{{message}}"
        end
      end
    end
  end
end
