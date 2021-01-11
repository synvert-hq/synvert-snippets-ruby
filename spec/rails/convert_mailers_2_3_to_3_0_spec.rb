# encoding: utf-8

require 'spec_helper'

RSpec.describe 'Convert rails mailers from 2.3 to 3.0' do
  let(:rewriter_name) { 'rails/convert_mailers_2_3_to_3_0' }
  let(:notifier_content) { '
class Notifier < ActionMailer::Base
  def signup_notification(recipient)
    recipients      recipient.email_address_with_name
    subject         "New account information"
    from            "system@example.com"
    sent_on         Time.now
    content_type    "multipart/alternative"
    body            :account => recipient
  end
end
  '}
  let(:notifier_rewritten_content) { '
class Notifier < ActionMailer::Base
  def signup_notification(recipient)
    @account = recipient
    mail(:to => recipient.email_address_with_name, :subject => "New account information", :from => "system@example.com", :date => Time.now)
  end
end
  '}
  let(:notifiers_controller_content) { '
class NotifiersController < ApplicationController
  def notify
    Notifier.deliver_signup_notification(recipient)

    message = Notifier.create_signup_notification(recipient)
    Notifier.deliver(message)
  end
end
  '}
  let(:notifiers_controller_rewritten_content) { '
class NotifiersController < ApplicationController
  def notify
    Notifier.signup_notification(recipient).deliver

    message = Notifier.signup_notification(recipient)
    message.deliver
  end
end
  '}
  let(:fake_file_paths) { %w[app/mailers/notifier.rb app/controllers/notifiers_controller.rb] }
  let(:test_contents) { [notifier_content, notifiers_controller_content] }
  let(:test_rewritten_contents) { [notifier_rewritten_content, notifiers_controller_rewritten_content] }

  include_examples 'convertable with multiple files'
end
